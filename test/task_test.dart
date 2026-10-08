import 'package:test/test.dart';

import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/urgent_task.dart';

void main() {
  group('Task', () {
    test('crée une tâche urgente correctement', () {
      final task = UrgentTask(
        id: 1,
        title: 'Faire le rapport',
        dueDate: DateTime(2026, 10, 15),
      );

      expect(task.id, 1);
      expect(task.title, 'Faire le rapport');
      expect(task.priority, Priority.high);
      expect(task.isCompleted, false);
      expect(task.dueDate, DateTime(2026, 10, 15));
    });

    test('une tâche peut être marquée comme terminée', () {
      final task = UrgentTask(
        id: 2,
        title: 'Préparer la présentation',
      );

      expect(task.isCompleted, false);

      task.complete();

      expect(task.isCompleted, true);
    });

    test('toJson retourne les bonnes informations', () {
      final task = UrgentTask(
        id: 3,
        title: 'Faire les tests',
        dueDate: DateTime(2026, 10, 20),
      );

      final json = task.toJson();

      expect(json['id'], 3);
      expect(json['title'], 'Faire les tests');
      expect(json['priority'], 'high');
      expect(json['isCompleted'], false);
      expect(json['type'], 'urgent');
    });
  });
}