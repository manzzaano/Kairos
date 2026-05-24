import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_shapes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/supabase_sync_service.dart';
import '../../../tasks/data/models/task_object.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';

class SyncSheet extends StatefulWidget {
  const SyncSheet({super.key});

  @override
  State<SyncSheet> createState() => _SyncSheetState();
}

class _SyncSheetState extends State<SyncSheet> {
  late List<_SyncStep> steps;
  int completedSteps = 0;
  String? _resultSummary;

  @override
  void initState() {
    super.initState();
    steps = [
      _SyncStep('Detectando cambios locales'),
      _SyncStep('Enviando datos al servidor'),
      _SyncStep('Descargando cambios remotos'),
      _SyncStep('Sincronización completada'),
    ];
    _runSync();
  }

  Future<void> _runSync() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final user = Supabase.instance.client.auth.currentUser;

    // Sin autenticación → informar y salir
    if (user == null) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Inicia sesión para sincronizar con la nube'),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        navigator.pop();
      }
      return;
    }

    try {
      // Step 1: detectar cambios locales
      final realm = getIt<Realm>();
      final allTasks = realm.all<TaskObject>().toList();
      final pendingTasks = allTasks.where((t) => !t.isSynced).toList();
      _markStepComplete();

      // Step 2: push solo las tareas sin sincronizar
      final syncService = getIt<SupabaseSyncService>();
      int pushed = 0;
      try {
        if (pendingTasks.isNotEmpty) {
          pushed = await syncService.pushTasks(pendingTasks);
          // Marcar como sincronizadas SOLO si el push fue exitoso
          realm.write(() {
            for (final task in pendingTasks) {
              task.isSynced = true;
            }
          });
        }
      } catch (pushError) {
        // Push falla → continuamos con pull para no bloquear sync
        debugPrint('[Sync] Push error: $pushError');
      }
      _markStepComplete();

      // Step 3: pull desde servidor (bidireccional)
      int pulled = 0;
      try {
        final remoteTasks = await syncService.pullTasks();
        pulled = await _mergeRemoteTasks(realm, remoteTasks);
      } catch (pullError) {
        debugPrint('[Sync] Pull error: $pullError');
      }
      _markStepComplete();

      // Step 4: completado — guardar timestamp de última sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_ts', DateTime.now().toIso8601String());

      _resultSummary = '↑ $pushed enviadas  ·  ↓ $pulled recibidas';
      _markStepComplete();

      // Recargar BLoC para reflejar cambios en UI
      if (mounted) {
        context.read<TaskBloc>().add(const LoadTasksRequested());
      }

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) navigator.pop();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(msg)));
        await Future.delayed(const Duration(milliseconds: 600));
        navigator.pop();
      }
    }
  }

  /// Merge bidireccional: inserta en Realm las tareas remotas que no existen localmente.
  /// Estrategia: local wins — si la tarea ya existe en Realm, se mantiene la versión local.
  /// Las tareas nuevas del servidor se añaden con isSynced = true.
  Future<int> _mergeRemoteTasks(
      Realm realm, List<Map<String, dynamic>> remoteTasks) async {
    if (remoteTasks.isEmpty) return 0;

    // Conjunto de IDs locales (ObjectId → hex string)
    final localIds =
        realm.all<TaskObject>().map((t) => t.id.hexString).toSet();

    int merged = 0;
    realm.write(() {
      for (final remote in remoteTasks) {
        final remoteIdStr = remote['id'] as String?;
        if (remoteIdStr == null) continue;

        // Si ya existe localmente → skip (local wins)
        if (localIds.contains(remoteIdStr)) continue;

        // Tarea nueva del servidor → insertar en Realm
        try {
          final objectId = ObjectId.fromHexString(remoteIdStr);
          final priorityInt = remote['priority'] as int? ?? 2;
          final obj = TaskObject(
            objectId,
            remote['title'] as String? ?? 'Sin título',
            _intToPriority(priorityInt),
            remote['energy'] as int? ?? 2,
            remote['estimated_minutes'] as int? ?? 25,
            remote['completed'] as bool? ?? false,
            true, // isSynced — viene del servidor
            '',   // project — no sincronizado aún
          );
          obj.description = remote['description'] as String?;
          obj.completedAt = remote['completed_at'] != null
              ? DateTime.tryParse(remote['completed_at'] as String)
              : null;
          obj.createdAt = remote['created_at'] != null
              ? DateTime.tryParse(remote['created_at'] as String)
              : DateTime.now();
          realm.add(obj);
          merged++;
        } catch (e) {
          // ID inválido o campo faltante → skip silencioso
          debugPrint('[Sync] Merge error para id $remoteIdStr: $e');
        }
      }
    });
    return merged;
  }

  /// Convierte prioridad int (Supabase) → String (Realm).
  static String _intToPriority(int p) =>
      p >= 3 ? 'high' : p == 2 ? 'medium' : 'low';

  void _markStepComplete() {
    if (mounted) {
      setState(() {
        if (completedSteps < steps.length) {
          steps[completedSteps].isComplete = true;
          completedSteps++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: kc.line2,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sincronizando datos',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w600, color: kc.text),
          ),
          const SizedBox(height: 24),
          ...steps.asMap().entries.map((e) {
            final idx = e.key;
            final step = e.value;
            final isActive = idx == completedSteps;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: step.isComplete ? kc.accent : kc.line,
                    ),
                    child: step.isComplete
                        ? const Icon(Icons.check,
                            size: 16, color: Color(0xFF1A0A00))
                        : isActive
                            ? Padding(
                                padding: const EdgeInsets.all(6),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(kc.text),
                                ),
                              )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.label,
                      style: AppTypography.body13.copyWith(color: kc.text2),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (_resultSummary != null && completedSteps == steps.length) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: kc.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _resultSummary!,
                style: AppTypography.mono11.copyWith(color: kc.accent),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: completedSteps == steps.length
                  ? () => Navigator.of(context).pop()
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: kc.text,
                side: BorderSide(color: kc.line),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppShapes.btnRadius)),
              ),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStep {
  final String label;
  bool isComplete = false;
  _SyncStep(this.label);
}
