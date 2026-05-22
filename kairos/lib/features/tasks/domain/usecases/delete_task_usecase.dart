import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../repositories/i_task_repository.dart';

class DeleteTaskUseCase extends UseCase<void, String> {
  final ITaskRepository repository;
  DeleteTaskUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteTask(id);
}
