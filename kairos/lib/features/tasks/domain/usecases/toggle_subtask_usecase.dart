import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../entities/task.dart';
import '../repositories/i_task_repository.dart';

class ToggleSubtaskUseCase {
  final ITaskRepository repository;
  const ToggleSubtaskUseCase(this.repository);

  Future<Either<Failure, Task>> call(String taskId, int subtaskIndex) =>
      repository.toggleSubtask(taskId, subtaskIndex);
}
