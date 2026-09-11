import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_clean_architecture_template/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_clean_architecture_template/features/tasks/domain/repositories/task_repository.dart';
import 'package:flutter_clean_architecture_template/features/tasks/domain/usecases/create_task_usecase.dart';

class FakeTaskRepository implements TaskRepository {
  TaskEntity? createdTask;

  @override
  Future<void> createTask(TaskEntity task) async {
    createdTask = task;
  }

  @override
  Future<void> deleteTask(String id) {
    throw UnimplementedError();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<TaskEntity>> getTasks() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(TaskEntity task) {
    throw UnimplementedError();
  }
}

void main() {
  late FakeTaskRepository repository;
  late CreateTaskUseCase useCase;

  setUp(() {
    repository = FakeTaskRepository();
    useCase = CreateTaskUseCase(repository);
  });

  test('passes task to repository when called', () async {
    const task = TaskEntity(
      title: 'Learn Clean Architecture',
      description: 'Write the first unit test',
    );

    await useCase(task);

    expect(repository.createdTask, same(task));
  });
}
