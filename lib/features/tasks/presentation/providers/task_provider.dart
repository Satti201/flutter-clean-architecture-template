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

final taskActionProvider = StateProvider<AsyncValue<void>>(
  (ref) => const AsyncValue.data(null),
);

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
    await createTaskUseCase(task);
    final tasks = await getTasksUseCase();
    state = AsyncValue.data(tasks);
  }

  Future<void> updateTask(TaskEntity task) async {
    await updateTaskUseCase(task);
    final tasks = await getTasksUseCase();
    state = AsyncValue.data(tasks);
  }

  Future<void> deleteTask(String id) async {
    await deleteTaskUseCase(id);
    final tasks = await getTasksUseCase();
    state = AsyncValue.data(tasks);
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
