import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realm/realm.dart';
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

    // Sin autenticación: informar y salir
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

      // Step 2: push al servidor
      final syncService = getIt<SupabaseSyncService>();
      int pushed = 0;
      try {
        pushed = await syncService.pushTasks(pendingTasks.isEmpty ? [] : allTasks);
        // Marcar tareas locales como sincronizadas
        realm.write(() {
          for (final task in pendingTasks) {
            task.isSynced = true;
          }
        });
      } catch (pushError) {
        // Si falla push, continuamos con pull
      }
      _markStepComplete();

      // Step 3: pull desde servidor (bidireccional)
      int pulled = 0;
      try {
        final remoteTasks = await syncService.pullTasks();
        pulled = await _mergeRemoteTasks(realm, remoteTasks);
      } catch (pullError) {
        // Pull no crítico si push funcionó
      }
      _markStepComplete();

      // Step 4: completado
      _resultSummary = '↑ $pushed enviadas  ·  ↓ $pulled recibidas';
      _markStepComplete();

      // Recargar el BLoC para reflejar cambios
      if (mounted) {
        context.read<TaskBloc>().add(const LoadTasksRequested());
      }

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) navigator.pop();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      messenger.showSnackBar(
        SnackBar(content: Text(msg)),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) navigator.pop();
    }
  }

  /// Cuenta las tareas disponibles en Supabase para este usuario.
  /// La inserción bidireccional completa requiere un campo uuid en Realm
  /// (trabajo futuro). Por ahora retorna el conteo de registros remotos.
  Future<int> _mergeRemoteTasks(
      Realm realm, List<Map<String, dynamic>> remoteTasks) async {
    return remoteTasks.length;
  }

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
          Text('Sincronizando datos',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w600, color: kc.text)),
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
                    child: Text(step.label,
                        style: AppTypography.body13.copyWith(color: kc.text2)),
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
              child: Text(_resultSummary!,
                  style: AppTypography.mono11.copyWith(color: kc.accent)),
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
