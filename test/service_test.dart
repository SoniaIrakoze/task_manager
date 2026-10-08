import 'dart:io';

import 'package:test/test.dart';

import 'package:task_manager/exceptions/task_exceptions.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/urgent_task.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/task_service.dart';
import 'package:task_manager/storage/json_storage.dart';

void main() {
  late TaskRepository repository;
  late JsonStorage storage;
  late TaskService service;
  late Directory temporaryDirectory;

  setUp(() {
    repository = TaskRepository();

    temporaryDirectory =
        Directory.systemTemp.createTempSync('task_service_test_');

    storage = JsonStorage(
      '${temporaryDirectory.path}/tasks.json',
    );

    service = TaskService(
      repository: repository,
      storage: storage,
    );
  });

  tearDown(() {
    if (temporaryDirectory.existsSync()) {
      temporaryDirectory.deleteSync(recursive: true);
    }
  });

  test('ajoute une tâche et la sauvegarde', () async {
    final task = UrgentTask(
      id: 1,
      title: 'Faire le rapport',
    );

    await service.addTask(task);

    final tasks = await service.getAllTasks();

    expect(tasks.length, 1);
    expect(tasks.first.title, 'Faire le rapport');

    final file = File('${temporaryDirectory.path}/tasks.json');

    expect(await file.exists(), true);
  });

  test('termine une tâche', () async {
    final task = UrgentTask(
      id: 2,
      title: 'Préparer la réunion',
    );

    await service.addTask(task);

    await service.completeTask(2);

    final result = await service.getTaskById(2);

    expect(result.isCompleted, true);
  });

  test('lance une exception si on termine une tâche inexistante',
      () async {
    expect(
      () => service.completeTask(999),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('supprime une tâche', () async {
    final task = UrgentTask(
      id: 3,
      title: 'Tâche à supprimer',
    );

    await service.addTask(task);

    await service.deleteTask(3);

    final tasks = await service.getAllTasks();

    expect(tasks, isEmpty);
  });

  test('trie les tâches par priorité', () async {
    final lowTask = TestTask(
      id: 4,
      title: 'Tâche faible',
      priority: Priority.low,
    );

    final highTask = TestTask(
      id: 5,
      title: 'Tâche urgente',
      priority: Priority.high,
    );

    final mediumTask = TestTask(
      id: 6,
      title: 'Tâche moyenne',
      priority: Priority.medium,
    );

    await service.addTask(lowTask);
    await service.addTask(highTask);
    await service.addTask(mediumTask);

    final sortedTasks = await service.sortByPriority();

    expect(sortedTasks[0].priority, Priority.high);
    expect(sortedTasks[1].priority, Priority.medium);
    expect(sortedTasks[2].priority, Priority.low);
  });

  test('trie les tâches par date', () async {
    final laterTask = TestTask(
      id: 7,
      title: 'Tâche plus tard',
      priority: Priority.low,
      dueDate: DateTime(2026, 12, 1),
    );

    final earlierTask = TestTask(
      id: 8,
      title: 'Tâche urgente',
      priority: Priority.high,
      dueDate: DateTime(2026, 10, 10),
    );

    await service.addTask(laterTask);
    await service.addTask(earlierTask);

    final sortedTasks = await service.sortByDate();

    expect(sortedTasks[0].id, 8);
    expect(sortedTasks[1].id, 7);
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