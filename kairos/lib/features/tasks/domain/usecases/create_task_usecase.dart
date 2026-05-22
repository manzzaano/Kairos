import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/task.dart';
import '../repositories/i_task_repository.dart';

class CreateTaskUseCase extends UseCase<Task, TaskParams> {
  final ITaskRepository repository;
  CreateTaskUseCase(this.repository);
  @override
  Future<Either<Failure, Task>> call(TaskParams params) =>
      repository.createTask(params);
}
