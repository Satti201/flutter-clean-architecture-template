import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_clean_architecture_template/core/error/data_exception.dart';
import 'package:flutter_clean_architecture_template/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:flutter_clean_architecture_template/features/tasks/data/models/task_model.dart';
import 'package:flutter_clean_architecture_template/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:flutter_clean_architecture_template/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_clean_architecture_template/features/tasks/domain/exceptions/task_exception.dart';

class FakeTaskRemoteDataSource implements TaskRemoteDataSource {
  TaskModel? createdTask;

  List<TaskModel> tasksToReturn = [];

  Object? errorToThrow;

  @override
  Future<void> createTask(TaskModel task) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    createdTask = task;
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    return tasksToReturn;
  }

  @override
  Future<TaskModel?> getTaskById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(TaskModel task) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String id) {
    throw UnimplementedError();
  }
}

void main() {
  late FakeTaskRemoteDataSource remoteDataSource;
  late TaskRepositoryImpl repository;

  setUp(() {
    remoteDataSource = FakeTaskRemoteDataSource();
    repository = TaskRepositoryImpl(remoteDataSource);
  });

  group('createTask', () {
    test(
      'converts TaskEntity to TaskModel and passes it to datasource',
      () async {
        const task = TaskEntity(
          id: 'task-1',
          title: 'Learn testing',
          description: 'Test repository mapping',
          isCompleted: true,
        );

        await repository.createTask(task);

        final createdTask = remoteDataSource.createdTask;

        expect(createdTask, isNotNull);
        expect(createdTask!.id, task.id);
        expect(createdTask.title, task.title);
        expect(createdTask.description, task.description);
        expect(createdTask.isCompleted, task.isCompleted);
      },
    );

    test(
      'throws TaskException when datasource throws DataException',
      () async {
        remoteDataSource.errorToThrow = const DataException(
          message: 'Missing or insufficient permissions',
          code: 'permission-denied',
        );

        const task = TaskEntity(
          title: 'Blocked task',
        );

        await expectLater(
          repository.createTask(task),
          throwsA(
            isA<TaskException>().having(
              (error) => error.message,
              'message',
              'You do not have permission to perform this action',
            ),
          ),
        );
      },
    );
  });

  group('getTasks', () {
    test(
      'returns datasource models as domain entities',
      () async {
        remoteDataSource.tasksToReturn = const [
          TaskModel(
            id: '1',
            title: 'Task one',
            description: 'First',
            isCompleted: false,
          ),
          TaskModel(
            id: '2',
            title: 'Task two',
            description: 'Second',
            isCompleted: true,
          ),
        ];

        final result = await repository.getTasks();

        expect(result, hasLength(2));
        expect(result.first, isA<TaskEntity>());
        expect(result.first.id, '1');
        expect(result.first.title, 'Task one');
        expect(result.last.isCompleted, true);
      },
    );
  });
}
