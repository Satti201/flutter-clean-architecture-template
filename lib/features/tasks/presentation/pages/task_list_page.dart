import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../widgets/create_task_sheet.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(taskProvider.notifier).loadTasks();
    });
  }

  Future<void> _showCreateTaskSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const CreateTaskSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: taskState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(taskProvider.notifier).loadTasks();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Card(
                child: ListTile(
                  title: Text(task.title),
                  subtitle: task.description == null
                      ? null
                      : Text(task.description!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final updatedTask = TaskEntity(
                            id: task.id,
                            title: task.title,
                            description: task.description,
                            isCompleted: !task.isCompleted,
                          );

                          await ref
                              .read(taskProvider.notifier)
                              .updateTask(updatedTask);
                        },
                        icon: Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                        ),
                      ),
                      IconButton(
                        onPressed: task.id == null
                            ? null
                            : () async {
                                await ref
                                    .read(taskProvider.notifier)
                                    .deleteTask(task.id!);
                              },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTaskSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
