import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kairos/core/error/failures.dart';
import 'package:kairos/features/tasks/domain/entities/task.dart';
import 'package:kairos/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:kairos/features/tasks/domain/usecases/create_task_usecase.dart';

class MockTaskRepository extends Mock implements ITaskRepository {}

class FakeTaskParams extends Fake implements TaskParams {}

void main() {
  late CreateTaskUseCase useCase;
  late MockTaskRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeTaskParams());
  });

  setUp(() {
    mockRepo = MockTaskRepository();
    useCase = CreateTaskUseCase(mockRepo);
  });

  const validParams = TaskParams(
    title: 'Estudiar Flutter',
    priority: Priority.high,
    energyLevel: 3,
  );

  final fakeTask = Task(
    id: 'abc-123',
    title: 'Estudiar Flutter',
    priority: Priority.high,
    energyLevel: 3,
    createdAt: DateTime(2026, 5, 23),
  );

  test('returns Task when repository succeeds', () async {
    when(() => mockRepo.createTask(any())).thenAnswer((_) async => Right(fakeTask));
    final result = await useCase(validParams);
    expect(result, Right<Failure, Task>(fakeTask));
    verify(() => mockRepo.createTask(validParams)).called(1);
  });

  test('returns CacheFailure when repository fails', () async {
    const failure = CacheFailure('Error al guardar la tarea.');
    when(() => mockRepo.createTask(any())).thenAnswer((_) async => const Left(failure));
    final result = await useCase(validParams);
    expect(result, const Left<Failure, Task>(failure));
  });

  test('repository not called when use case not invoked', () {
    verifyNever(() => mockRepo.createTask(any()));
  });

  test('params equality — same params are equal', () {
    const p1 = TaskParams(title: 'Test', priority: Priority.low, energyLevel: 1);
    const p2 = TaskParams(title: 'Test', priority: Priority.low, energyLevel: 1);
    expect(p1, p2);
  });

  test('params equality — different title not equal', () {
    const p1 = TaskParams(title: 'Test A', priority: Priority.low, energyLevel: 1);
    const p2 = TaskParams(title: 'Test B', priority: Priority.low, energyLevel: 1);
    expect(p1, isNot(p2));
  });
}
