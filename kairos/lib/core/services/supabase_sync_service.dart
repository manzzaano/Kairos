import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/tasks/data/models/task_object.dart';

class SupabaseSyncService {
  final SupabaseClient supabase;

  SupabaseSyncService({required this.supabase});

  Future<int> pushTasks(List<TaskObject> tasks) async {
    try {
      int syncedCount = 0;
      for (final task in tasks) {
        if (!task.isSynced) {
          await supabase.from('tasks').upsert({
            'id': task.id.toString(),
            'title': task.title,
            'priority': task.priority,
            'energy': task.energyLevel,
            'project': task.project,
            'is_completed': task.isDone,
            'completed_at': task.completedAt?.toIso8601String(),
            'created_at': task.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
            'is_synced': true,
          });
          syncedCount++;
        }
      }
      return syncedCount;
    } catch (e) {
      rethrow;
    }
  }
}
