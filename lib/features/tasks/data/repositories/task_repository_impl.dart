import '../../../../core/error/data_exception.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/exceptions/task_exception.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

enum _TaskOperation {
  create,
  read,
  update,
  delete,
}

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  Future<T> _handleDataOperation<T>(
    Future<T> Function() action,
    _TaskOperation operation,
  ) async {
    try {
      return await action();
    } on DataException catch (error) {
      throw TaskException(
        _mapDataExceptionMessage(
          error,
          operation,
        ),
      );
    }
  }

  @override
  Future<void> createTask(TaskEntity task) {
    final taskModel = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
    );

    return _handleDataOperation(
      () => remoteDataSource.createTask(taskModel),
      _TaskOperation.create,
    );
  }

  @override
  Future<List<TaskEntity>> getTasks() {
    return _handleDataOperation(
      () async {
        final taskModels = await remoteDataSource.getTasks();
        return taskModels;
      },
      _TaskOperation.read,
    );
  }

  @override
  Future<TaskEntity?> getTaskById(String id) {
    return _handleDataOperation(
      () => remoteDataSource.getTaskById(id),
      _TaskOperation.read,
    );
  }

  @override
  Future<void> updateTask(TaskEntity task) {
    final taskModel = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
    );

    return _handleDataOperation(
      () => remoteDataSource.updateTask(taskModel),
      _TaskOperation.update,
    );
  }

  @override
  Future<void> deleteTask(String id) {
    return _handleDataOperation(
      () => remoteDataSource.deleteTask(id),
      _TaskOperation.delete,
    );
  }

  String _mapDataExceptionMessage(
    DataException error,
    _TaskOperation operation,
  ) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action';

      case 'unavailable':
        return 'Task service is currently unavailable. Please try again';

      case 'network-request-failed':
        return 'Please check your internet connection';

      default:
        return switch (operation) {
          _TaskOperation.create =>
            'Unable to create task. Please try again',
          _TaskOperation.read =>
            'Unable to load tasks. Please try again',
          _TaskOperation.update =>
            'Unable to update task. Please try again',
          _TaskOperation.delete =>
            'Unable to delete task. Please try again',
        };
    }
  }
}
