import 'dart:io';

import 'package:test/test.dart';

import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/urgent_task.dart';
import 'package:task_manager/storage/json_storage.dart';

void main() {
  late Directory temporaryDirectory;
  late JsonStorage storage;

  setUp(() {
    temporaryDirectory = Directory.systemTemp.createTempSync('task_manager_test_');

    storage = JsonStorage(
      '${temporaryDirectory.path}/tasks.json',
    );
  });

  tearDown(() {
    if (temporaryDirectory.existsSync()) {
      temporaryDirectory.deleteSync(recursive: true);
    }
  });

  test('sauvegarde les tâches dans un fichier JSON', () async {
    final tasks = [
      UrgentTask(
        id: 1,
        title: 'Faire le rapport',
        priority: Priority.high,
      ),
    ];

    await storage.save(tasks);

    final file = File('${temporaryDirectory.path}/tasks.json');

    expect(await file.exists(), true);

    final content = await file.readAsString();

    expect(content.contains('Faire le rapport'), true);
    expect(content.contains('"priority": "high"'), true);
  });

  test('charge les tâches depuis le fichier JSON', () async {
    final tasks = [
      UrgentTask(
        id: 2,
        title: 'Préparer la réunion',
        priority: Priority.high,
      ),
    ];

    await storage.save(tasks);

    final loadedTasks = await storage.load();

    expect(loadedTasks.length, 1);
    expect(loadedTasks.first.id, 2);
    expect(loadedTasks.first.title, 'Préparer la réunion');
    expect(loadedTasks.first.priority, Priority.high);
  });

  test('retourne une liste vide si le fichier n’existe pas', () async {
    final loadedTasks = await storage.load();

    expect(loadedTasks, isEmpty);
  });
}