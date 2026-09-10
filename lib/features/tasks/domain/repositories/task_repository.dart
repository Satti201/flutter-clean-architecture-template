import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<void> createTask(TaskEntity task);

  Future<List<TaskEntity>> getTasks();

  Future<TaskEntity?> getTaskById(String id);

  Future<void> updateTask(TaskEntity task);

  Future<void> deleteTask(String id);
}