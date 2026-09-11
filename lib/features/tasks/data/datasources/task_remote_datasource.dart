import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/data_exception.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<void> createTask(TaskModel task);

  Future<List<TaskModel>> getTasks();

  Future<TaskModel?> getTaskById(String id);

  Future<void> updateTask(TaskModel task);

  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl(this.firestore);

  Future<T> _handleFirebaseCall<T>(
    Future<T> Function() action, {
    required String fallbackMessage,
  }) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      throw DataException(
        message: error.message ?? fallbackMessage,
        code: error.code,
      );
    }
  }

  @override
  Future<void> createTask(TaskModel task) {
    return _handleFirebaseCall(
      () async {
        await firestore.collection('tasks').add(task.toJson());
      },
      fallbackMessage: 'Failed to create task',
    );
  }

  @override
  Future<List<TaskModel>> getTasks() {
    return _handleFirebaseCall(
      () async {
        final snapshot = await firestore.collection('tasks').get();

        return snapshot.docs.map((doc) {
          return TaskModel.fromJson({
            ...doc.data(),
            'id': doc.id,
          });
        }).toList();
      },
      fallbackMessage: 'Failed to load tasks',
    );
  }

  @override
  Future<TaskModel?> getTaskById(String id) {
    return _handleFirebaseCall(
      () async {
        final doc = await firestore.collection('tasks').doc(id).get();

        if (!doc.exists) {
          return null;
        }

        return TaskModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      },
      fallbackMessage: 'Failed to load task',
    );
  }

  @override
  Future<void> updateTask(TaskModel task) {
    final id = task.id;

    if (id == null || id.isEmpty) {
      throw ArgumentError(
        'Cannot update a task without an ID',
      );
    }

    return _handleFirebaseCall(
      () async {
        await firestore.collection('tasks').doc(id).update(task.toJson());
      },
      fallbackMessage: 'Failed to update task',
    );
  }

  @override
  Future<void> deleteTask(String id) {
    if (id.isEmpty) {
      throw ArgumentError(
        'Cannot delete a task with an empty ID',
      );
    }

    return _handleFirebaseCall(
      () async {
        await firestore.collection('tasks').doc(id).delete();
      },
      fallbackMessage: 'Failed to delete task',
    );
  }
}
