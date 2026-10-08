import 'package:test/test.dart';

import 'package:task_manager/exceptions/task_exceptions.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/repositories/task_repository.dart';

void main() {
  group('TaskRepository', () {
    late TaskRepository repository;

    setUp(() {
      repository = TaskRepository();
    });

    test('ajoute une tâche', () async {
      final task = TestTask(
        id: 1,
        title: 'Faire le rapport',
        priority: Priority.high,
      );

      await repository.add(task);

      final tasks = await repository.getAll();

      expect(tasks.length, 1);
      expect(tasks.first.title, 'Faire le rapport');
    });

    test('récupère une tâche par son ID', () async {
      final task = TestTask(
        id: 2,
        title: 'Préparer la réunion',
        priority: Priority.medium,
      );

      await repository.add(task);

      final result = await repository.getById(2);

      expect(result, isNotNull);
      expect(result!.title, 'Préparer la réunion');
    });

    test('met à jour une tâche', () async {
      final task = TestTask(
        id: 3,
        title: 'Ancien titre',
        priority: Priority.low,
      );

      await repository.add(task);

      task.title = 'Nouveau titre';

      await repository.update(task);

      final result = await repository.getById(3);

      expect(result!.title, 'Nouveau titre');
    });

    test('supprime une tâche', () async {
      final task = TestTask(
        id: 4,
        title: 'Tâche à supprimer',
        priority: Priority.low,
      );

      await repository.add(task);
      await repository.delete(4);

      final result = await repository.getById(4);

      expect(result, isNull);
    });

    test('lance TaskNotFoundException si la tâche à supprimer n’existe pas',
        () async {
      expect(
        () => repository.delete(999),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('refuse une tâche avec un titre vide', () async {
      final task = TestTask(
        id: 5,
        title: '',
        priority: Priority.low,
      );

      expect(
        () => repository.add(task),
        throwsA(isA<InvalidTaskException>()),
      );
    });
  });
}

class TestTask extends Task {
  TestTask({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.isCompleted = false,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'type': 'test',
    };
  }

  @override
  String toString() {
    return title;
  }
}