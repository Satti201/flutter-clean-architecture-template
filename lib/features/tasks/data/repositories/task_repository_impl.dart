import '../../../../core/error/data_exception.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/exceptions/task_exception.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createTask(TaskEntity task) async {
    final taskModel = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
    );

    try {
      await remoteDataSource.createTask(taskModel);
    } on DataException catch (error) {
      throw TaskException(
        _mapDataExceptionMessage(error),
      );
    }
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    final taskModels = await remoteDataSource.getTasks();
    return taskModels;
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final taskModel = await remoteDataSource.getTaskById(id);
    return taskModel;
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final taskModel = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
    );

    await remoteDataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(String id) async {
    await remoteDataSource.deleteTask(id);
  }

  String _mapDataExceptionMessage(DataException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to create this task';

      case 'unavailable':
        return 'Task service is currently unavailable. Please try again';

      case 'network-request-failed':
        return 'Please check your internet connection';

      default:
        return 'Unable to create task. Please try again';
    }
  }
}
