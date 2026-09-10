import '../../domain/entities/task_entity.dart';
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

    await remoteDataSource.createTask(taskModel);
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    final taskModels = await remoteDataSource.getTasks();
    return taskModels;
  }

  @override
  Future<TaskEntity?> getTaskById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(TaskEntity task) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String id) {
    throw UnimplementedError();
  }
}
