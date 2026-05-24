import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../entities/task.dart';

abstract class ITaskRepository {
  Future<Either<Failure, List<Task>>> getTasks({bool todayOnly = false});
  Future<Either<Failure, Task>> createTask(TaskParams params);
  Future<Either<Failure, Task>> toggleTask(String id);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, Task>> toggleSubtask(String taskId, int subtaskIndex);
}
