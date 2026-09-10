import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/tasks/data/datasources/task_remote_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/create_task_usecase.dart';
import '../../features/tasks/domain/usecases/delete_task_usecase.dart';
import '../../features/tasks/domain/usecases/get_task_by_id_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../features/tasks/domain/usecases/update_task_usecase.dart';

class Injection {
  static late final TaskRepository taskRepository;

  static late final CreateTaskUseCase createTaskUseCase;
  static late final GetTasksUseCase getTasksUseCase;
  static late final GetTaskByIdUseCase getTaskByIdUseCase;
  static late final UpdateTaskUseCase updateTaskUseCase;
  static late final DeleteTaskUseCase deleteTaskUseCase;

  static void init() {
    final firestore = FirebaseFirestore.instance;

    final taskRemoteDataSource = TaskRemoteDataSourceImpl(
      firestore,
    );

    taskRepository = TaskRepositoryImpl(
      taskRemoteDataSource,
    );

    createTaskUseCase = CreateTaskUseCase(taskRepository);
    getTasksUseCase = GetTasksUseCase(taskRepository);
    getTaskByIdUseCase = GetTaskByIdUseCase(taskRepository);
    updateTaskUseCase = UpdateTaskUseCase(taskRepository);
    deleteTaskUseCase = DeleteTaskUseCase(taskRepository);
  }
}
