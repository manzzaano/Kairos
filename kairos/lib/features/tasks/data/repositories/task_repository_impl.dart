import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../datasources/task_realm_datasource.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final TaskRealmDataSource realmDataSource;

  TaskRepositoryImpl({required this.realmDataSource});

  @override
  Future<Either<Failure, List<Task>>> getTasks({bool todayOnly = false}) async {
    try {
      final tasks = await realmDataSource.getTasks(todayOnly: todayOnly);
      return Right(tasks);
    } catch (e) {
      return Left(CacheFailure('Failed to get tasks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(TaskParams params) async {
    try {
      final task = await realmDataSource.createTask(params);
      return Right(task);
    } catch (e) {
      return Left(CacheFailure('Failed to create task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Task>> toggleTask(String id) async {
    try {
      final task = await realmDataSource.toggleTask(id);
      return Right(task);
    } catch (e) {
      return Left(CacheFailure('Failed to toggle task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await realmDataSource.deleteTask(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete task: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Task>> toggleSubtask(
      String taskId, int subtaskIndex) async {
    try {
      final task = await realmDataSource.toggleSubtask(taskId, subtaskIndex);
      return Right(task);
    } catch (e) {
      return Left(CacheFailure('Failed to toggle subtask: ${e.toString()}'));
    }
  }
}
