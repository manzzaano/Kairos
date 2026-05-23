import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/tasks/data/models/task_object.dart';

class SupabaseSyncService {
  final SupabaseClient supabase;

  SupabaseSyncService({required this.supabase});

  /// Mapea prioridad String ('high'/'medium'/'low') → int (3/2/1) para la tabla Supabase.
  static int _priorityToInt(String priority) =>
      const {'high': 3, 'medium': 2, 'low': 1}[priority] ?? 2;

  /// Envía tareas locales sin sincronizar a Supabase.
  /// Retorna el número de tareas sincronizadas.
  Future<int> pushTasks(List<TaskObject> tasks) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      // Sin sesión activa: no podemos sincronizar con backend
      throw Exception('Usuario no autenticado. Inicia sesión para sincronizar.');
    }

    int syncedCount = 0;
    final errors = <String>[];

    for (final task in tasks) {
      if (!task.isSynced) {
        try {
          await supabase.from('tasks').upsert({
            'id': task.id.toString(),
            'user_id': userId,
            'title': task.title,
            'priority': _priorityToInt(task.priority),
            'energy': task.energyLevel,
            'estimated_minutes': task.estimateMinutes,
            'completed': task.isDone,
            'completed_at': task.completedAt?.toIso8601String(),
            'created_at':
                task.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          });
          syncedCount++;
        } catch (e) {
          errors.add(task.title);
        }
      }
    }

    if (errors.isNotEmpty && syncedCount == 0) {
      throw Exception('Error al sincronizar tareas. Comprueba la conexión.');
    }

    return syncedCount;
  }

  /// Descarga tareas del usuario desde Supabase.
  /// Retorna lista de mapas con los datos remotos.
  Future<List<Map<String, dynamic>>> pullTasks() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response as List);
  }
}
