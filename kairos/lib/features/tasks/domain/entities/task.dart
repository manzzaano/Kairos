import 'package:equatable/equatable.dart';

enum Priority { high, medium, low }

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final Priority priority;
  final int energyLevel;
  final String? dueLabel;
  final int estimateMinutes;
  final bool isDone;
  final bool isSynced;
  final String project;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final List<String> subtasks;
  final List<bool> subtasksDone;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.energyLevel,
    this.dueLabel = 'Hoy',
    this.estimateMinutes = 30,
    this.isDone = false,
    this.isSynced = false,
    this.project = 'Personal',
    this.completedAt,
    this.createdAt,
    this.subtasks = const [],
    this.subtasksDone = const [],
  });

  @override
  List<Object?> get props => [id, title, isDone, isSynced, completedAt, subtasksDone];
}

class TaskParams extends Equatable {
  final String title;
  final String? description;
  final Priority priority;
  final int energyLevel;
  final String? dueLabel;
  final int estimateMinutes;
  final String? project;
  final List<String> subtasks;

  const TaskParams({
    required this.title,
    this.description,
    required this.priority,
    required this.energyLevel,
    this.dueLabel = 'Hoy',
    this.estimateMinutes = 30,
    this.project,
    this.subtasks = const [],
  });

  @override
  List<Object?> get props => [title, priority, energyLevel, subtasks];
}

class GetTasksParams extends Equatable {
  final bool todayOnly;
  const GetTasksParams({this.todayOnly = false});
  @override
  List<Object?> get props => [todayOnly];
}
