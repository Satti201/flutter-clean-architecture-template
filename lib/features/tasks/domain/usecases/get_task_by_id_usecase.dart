import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTaskByIdUseCase {
  final TaskRepository repository;

  GetTaskByIdUseCase(this.repository);

  Future<TaskEntity?> call(String id) {
    return repository.getTaskById(id);
  }
}
