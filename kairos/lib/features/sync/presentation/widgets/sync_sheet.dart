import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realm/realm.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_shapes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/supabase_sync_service.dart';
import '../../../tasks/data/models/task_object.dart';

class SyncSheet extends StatefulWidget {
  const SyncSheet({super.key});

  @override
  State<SyncSheet> createState() => _SyncSheetState();
}

class _SyncSheetState extends State<SyncSheet> {
  late List<_SyncStep> steps;
  int completedSteps = 0;

  @override
  void initState() {
    super.initState();
    steps = [
      _SyncStep('Detectando cambios locales'),
      _SyncStep('Preparando datos'),
      _SyncStep('Sincronizando con servidor'),
      _SyncStep('Completado'),
    ];
    _runSync();
  }

  Future<void> _runSync() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Step 1: detect local changes
      final realm = getIt<Realm>();
      final tasks = realm.all<TaskObject>().toList();
      _markStepComplete();

      // Step 2: prepare data
      await Future.delayed(const Duration(milliseconds: 300));
      _markStepComplete();

      // Step 3: push to server
      final syncService = getIt<SupabaseSyncService>();
      await syncService.pushTasks(tasks);
      _markStepComplete();

      // Step 4: mark local records as synced
      realm.write(() {
        for (final task in tasks.where((t) => !t.isSynced)) {
          task.isSynced = true;
        }
      });
      _markStepComplete();

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error de sincronización: $e')),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) navigator.pop();
    }
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
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                        ? Icon(Icons.check, size: 16, color: Color(0xFF1A0A00))
                        : (isActive
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        kc.text)),
                              )
                            : null),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(step.label,
                        style: AppTypography.body13
                            .copyWith(color: kc.text2)),
                  ),
                ],
              ),
            );
          }),
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
