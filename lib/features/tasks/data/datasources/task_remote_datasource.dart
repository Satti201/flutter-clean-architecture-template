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

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await firestore.collection('tasks').add(task.toJson());
    } on FirebaseException catch (error) {
      throw DataException(
        message: error.message ?? 'Failed to create task',
        code: error.code,
      );
    }
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final snapshot = await firestore.collection('tasks').get();

    return snapshot.docs.map((doc) {
      return TaskModel.fromJson({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    final doc = await firestore.collection('tasks').doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return TaskModel.fromJson({
      ...doc.data()!,
      'id': doc.id,
    });
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final id = task.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Cannot update a task without an ID');
    }

    await firestore.collection('tasks').doc(id).update(task.toJson());
  }

  @override
  Future<void> deleteTask(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Cannot delete a task with an empty ID');
    }

    await firestore.collection('tasks').doc(id).delete();
  }
}
