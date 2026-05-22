import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/task.dart';
import '../repositories/i_task_repository.dart';

class ToggleTaskUseCase extends UseCase<Task, String> {
  final ITaskRepository repository;
  ToggleTaskUseCase(this.repository);
  @override
  Future<Either<Failure, Task>> call(String id) =>
      repository.toggleTask(id);
}
