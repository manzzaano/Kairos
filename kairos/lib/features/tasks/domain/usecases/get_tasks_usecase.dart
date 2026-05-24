import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/task.dart';
import '../repositories/i_task_repository.dart';

class GetTasksUseCase extends UseCase<List<Task>, GetTasksParams> {
  final ITaskRepository repository;
  GetTasksUseCase(this.repository);
  @override
  Future<Either<Failure, List<Task>>> call(GetTasksParams params) =>
      repository.getTasks();
}
