import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_clean_architecture_template/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_clean_architecture_template/features/tasks/domain/exceptions/task_exception.dart';
import 'package:flutter_clean_architecture_template/features/tasks/domain/repositories/task_repository.dart';
import 'package:flutter_clean_architecture_template/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:flutter_clean_architecture_template/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_clean_architecture_template/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:flutter_clean_architecture_template/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:flutter_clean_architecture_template/features/tasks/presentation/providers/task_provider.dart';

class FakeTaskRepository implements TaskRepository {
  List<TaskEntity> tasks = [];
  Object? errorToThrow;

  @override
  Future<void> createTask(TaskEntity task) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    tasks = [
      ...tasks,
      TaskEntity(
        id: task.id ?? 'generated-id',
        title: task.title,
        description: task.description,
        isCompleted: task.isCompleted,
      ),
    ];
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    return List<TaskEntity>.from(tasks);
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    for (final task in tasks) {
      if (task.id == id) {
        return task;
      }
    }

    return null;
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    tasks = tasks.map((existingTask) {
      return existingTask.id == task.id
          ? task
          : existingTask;
    }).toList();
  }

  @override
  Future<void> deleteTask(String id) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    tasks = tasks.where((task) => task.id != id).toList();
  }
}

void main() {
  late FakeTaskRepository repository;
  late TaskNotifier notifier;

  setUp(() {
    repository = FakeTaskRepository();

    notifier = TaskNotifier(
      getTasksUseCase: GetTasksUseCase(repository),
      createTaskUseCase: CreateTaskUseCase(repository),
      updateTaskUseCase: UpdateTaskUseCase(repository),
      deleteTaskUseCase: DeleteTaskUseCase(repository),
    );
  });

  test('starts in loading state', () {
    expect(notifier.state, const AsyncValue<List<TaskEntity>>.loading());
  });

  test('loadTasks sets state to data with repository tasks', () async {
    repository.tasks = const [
      TaskEntity(
        id: '1',
        title: 'Existing task',
      ),
    ];

    await notifier.loadTasks();

    expect(notifier.state.hasValue, true);
    expect(notifier.state.value, hasLength(1));
    expect(notifier.state.value!.first.title, 'Existing task');
  });

  test('loadTasks sets state to error when repository fails', () async {
    repository.errorToThrow = const TaskException('Failed to load tasks');

    await notifier.loadTasks();

    expect(notifier.state.hasError, true);
    expect(notifier.state.error, isA<TaskException>());
    expect(
      (notifier.state.error as TaskException).message,
      'Failed to load tasks',
    );
  });

  test('createTask adds task and refreshes state', () async {
    const task = TaskEntity(
      title: 'New task',
    );

    await notifier.createTask(task);

    expect(notifier.state.hasValue, true);
    expect(notifier.state.value, hasLength(1));
    expect(notifier.state.value!.first.title, 'New task');
    expect(notifier.state.value!.first.id, 'generated-id');
  });

  test('updateTask updates task and refreshes state', () async {
    repository.tasks = const [
      TaskEntity(
        id: '1',
        title: 'Old title',
        isCompleted: false,
      ),
    ];

    const updatedTask = TaskEntity(
      id: '1',
      title: 'Updated title',
      isCompleted: true,
    );

    await notifier.updateTask(updatedTask);

    expect(notifier.state.value, hasLength(1));
    expect(notifier.state.value!.first.title, 'Updated title');
    expect(notifier.state.value!.first.isCompleted, true);
  });

  test('deleteTask removes task and refreshes state', () async {
    repository.tasks = const [
      TaskEntity(
        id: '1',
        title: 'Delete me',
      ),
    ];

    await notifier.deleteTask('1');

    expect(notifier.state.hasValue, true);
    expect(notifier.state.value, isEmpty);
  });
}
