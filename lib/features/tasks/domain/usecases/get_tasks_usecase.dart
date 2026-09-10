import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<List<TaskEntity>> call() {
    return repository.getTasks();
  }
}
