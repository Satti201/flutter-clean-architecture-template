import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_clean_architecture_template/features/tasks/data/models/task_model.dart';

void main() {
  group('TaskModel.fromJson', () {
    test('creates TaskModel from valid json', () {
      final json = {
        'id': 'task-1',
        'title': 'Learn testing',
        'description': 'Test model mapping',
        'is_completed': true,
      };

      final model = TaskModel.fromJson(json);

      expect(model.id, 'task-1');
      expect(model.title, 'Learn testing');
      expect(model.description, 'Test model mapping');
      expect(model.isCompleted, true);
    });

    test('defaults isCompleted to false when missing', () {
      final json = {
        'id': 'task-2',
        'title': 'Default completion',
        'description': null,
      };

      final model = TaskModel.fromJson(json);

      expect(model.id, 'task-2');
      expect(model.title, 'Default completion');
      expect(model.description, isNull);
      expect(model.isCompleted, false);
    });
  });

  group('TaskModel.toJson', () {
    test('serializes task fields correctly', () {
      const model = TaskModel(
        id: 'task-1',
        title: 'Write tests',
        description: 'Test serialization',
        isCompleted: true,
      );

      final json = model.toJson();

      expect(json, {
        'title': 'Write tests',
        'description': 'Test serialization',
        'is_completed': true,
      });
    });

    test('does not include id because Firestore document id is canonical', () {
      const model = TaskModel(
        id: 'firestore-doc-id',
        title: 'No duplicate id',
      );

      final json = model.toJson();

      expect(json.containsKey('id'), false);
    });
  });
}
