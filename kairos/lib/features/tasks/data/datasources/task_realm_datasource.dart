import 'package:realm/realm.dart';
import '../models/task_object.dart';
import '../../domain/entities/task.dart';

abstract class TaskRealmDataSource {
  Future<List<Task>> getTasks({bool todayOnly = false});
  Future<Task> createTask(TaskParams params);
  Future<Task> toggleTask(String id);
  Future<void> deleteTask(String id);
  Future<Task> toggleSubtask(String taskId, int subtaskIndex);
}

class TaskRealmDataSourceImpl implements TaskRealmDataSource {
  final Realm realm;

  TaskRealmDataSourceImpl(this.realm);

  @override
  Future<List<Task>> getTasks({bool todayOnly = false}) async {
    try {
      final tasks = realm.all<TaskObject>();
      return tasks.map((obj) => obj.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  @override
  Future<Task> createTask(TaskParams params) async {
    try {
      final taskObject = TaskObject(
        ObjectId(),
        params.title,
        params.priority.toString().split('.').last,
        params.energyLevel,
        params.estimateMinutes,
        false,
        false,
        params.project ?? 'Personal',
        description: params.description,
        dueLabel: params.dueLabel ?? 'Hoy',
        createdAt: DateTime.now().toUtc(),
        subtasks: params.subtasks,
        subtasksDone: List.filled(params.subtasks.length, false),
      );
      realm.write(() => realm.add(taskObject));
      return taskObject.toEntity();
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  @override
  Future<Task> toggleTask(String id) async {
    try {
      final objectId = ObjectId.fromHexString(id);
      final taskObject = realm.find<TaskObject>(objectId);
      if (taskObject == null) throw Exception('Task not found');
      realm.write(() {
        taskObject.isDone = !taskObject.isDone;
        taskObject.completedAt =
            taskObject.isDone ? DateTime.now().toUtc() : null;
      });
      return taskObject.toEntity();
    } catch (e) {
      throw Exception('Failed to toggle task: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final objectId = ObjectId.fromHexString(id);
      final taskObject = realm.find<TaskObject>(objectId);
      if (taskObject != null) realm.write(() => realm.delete(taskObject));
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  @override
  Future<Task> toggleSubtask(String taskId, int subtaskIndex) async {
    try {
      final objectId = ObjectId.fromHexString(taskId);
      final taskObject = realm.find<TaskObject>(objectId);
      if (taskObject == null) throw Exception('Task not found');
      if (subtaskIndex < 0 || subtaskIndex >= taskObject.subtasksDone.length) {
        throw Exception('Subtask index out of range');
      }
      realm.write(() {
        taskObject.subtasksDone[subtaskIndex] =
            !taskObject.subtasksDone[subtaskIndex];
      });
      return taskObject.toEntity();
    } catch (e) {
      throw Exception('Failed to toggle subtask: $e');
    }
  }
}

extension TaskObjectExtension on TaskObject {
  Task toEntity() => Task(
        id: id.hexString,
        title: title,
        description: description,
        priority: Priority.values.firstWhere(
            (p) => p.toString().split('.').last == priority),
        energyLevel: energyLevel,
        dueLabel: dueLabel,
        estimateMinutes: estimateMinutes,
        isDone: isDone,
        isSynced: isSynced,
        project: project,
        completedAt: completedAt,
        createdAt: createdAt,
        subtasks: subtasks.toList(),
        subtasksDone: subtasksDone.toList(),
      );
}
