import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return Injection.getTasksUseCase;
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return Injection.createTaskUseCase;
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return Injection.updateTaskUseCase;
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return Injection.deleteTaskUseCase;
});

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TaskNotifier({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  }) : super(const AsyncValue.loading());

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return getTasksUseCase();
    });
  }

  Future<void> createTask(TaskEntity task) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await createTaskUseCase(task);
      return getTasksUseCase();
    });
  }

  Future<void> updateTask(TaskEntity task) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await updateTaskUseCase(task);
      return getTasksUseCase();
    });
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await deleteTaskUseCase(id);
      return getTasksUseCase();
    });
  }
}

final taskProvider = StateNotifierProvider<
    TaskNotifier,
    AsyncValue<List<TaskEntity>>
>((ref) {
  return TaskNotifier(
    getTasksUseCase: ref.read(getTasksUseCaseProvider),
    createTaskUseCase: ref.read(createTaskUseCaseProvider),
    updateTaskUseCase: ref.read(updateTaskUseCaseProvider),
    deleteTaskUseCase: ref.read(deleteTaskUseCaseProvider),
  );
});
