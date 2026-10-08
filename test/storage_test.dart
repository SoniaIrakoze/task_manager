import 'dart:io';

import 'package:task_manager/models/regular_task.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/urgent_task.dart';
import 'package:task_manager/storage/json_storage.dart';
import 'package:test/test.dart';

void main() {
  late Directory temporaryDirectory;
  late JsonStorage storage;

  setUp(() {
    temporaryDirectory =
        Directory.systemTemp.createTempSync('task_manager_test_');

    storage = JsonStorage(
      '${temporaryDirectory.path}${Platform.pathSeparator}tasks.json',
    );
  });

  tearDown(() {
    if (temporaryDirectory.existsSync()) {
      temporaryDirectory.deleteSync(recursive: true);
    }
  });

  test('sauvegarde les tâches dans un fichier JSON', () async {
    final tasks = [
      RegularTask(
        id: 1,
        title: 'Faire le rapport',
        priority: Priority.medium,
        dueDate: DateTime(2026, 10, 15),
      ),
    ];

    await storage.save(tasks);

    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}tasks.json',
    );

    expect(await file.exists(), isTrue);

    final content = await file.readAsString();

    expect(content.contains('Faire le rapport'), isTrue);
    expect(content.contains('"priority": "medium"'), isTrue);
    expect(content.contains('2026-10-15'), isTrue);
    expect(content.contains('"type": "regular"'), isTrue);
  });

  test('sauvegarde une tâche urgente avec son type', () async {
    final tasks = [
      UrgentTask(
        id: 1,
        title: 'Préparer la réunion',
        priority: Priority.high,
      ),
    ];

    await storage.save(tasks);

    final content = await File(
      '${temporaryDirectory.path}${Platform.pathSeparator}tasks.json',
    ).readAsString();

    expect(content.contains('"type": "urgent"'), isTrue);
    expect(content.contains('"priority": "high"'), isTrue);
  });

  test('charge les tâches depuis le fichier JSON', () async {
    final tasks = [
      RegularTask(
        id: 2,
        title: 'Préparer la réunion',
        priority: Priority.medium,
      ),
    ];

    await storage.save(tasks);

    final loadedTasks = await storage.load();

    expect(loadedTasks, hasLength(1));
    expect(loadedTasks.first, isA<RegularTask>());
    expect(loadedTasks.first.id, 2);
    expect(loadedTasks.first.title, 'Préparer la réunion');
    expect(loadedTasks.first.priority, Priority.medium);
  });

  test('reconstruit une tâche urgente depuis le JSON', () async {
    final tasks = [
      UrgentTask(
        id: 3,
        title: 'Présentation urgente',
        priority: Priority.high,
        dueDate: DateTime(2026, 10, 20),
      ),
    ];

    await storage.save(tasks);

    final loadedTasks = await storage.load();

    expect(loadedTasks, hasLength(1));
    expect(loadedTasks.first, isA<UrgentTask>());
    expect(loadedTasks.first.title, 'Présentation urgente');
    expect(loadedTasks.first.priority, Priority.high);
    expect(loadedTasks.first.dueDate, DateTime(2026, 10, 20));
  });

  test('conserve le statut terminé lors du chargement', () async {
    final tasks = [
      RegularTask(
        id: 4,
        title: 'Tâche terminée',
        priority: Priority.low,
        isCompleted: true,
      ),
    ];

    await storage.save(tasks);

    final loadedTasks = await storage.load();

    expect(loadedTasks, hasLength(1));
    expect(loadedTasks.first.isCompleted, isTrue);
  });

  test('retourne une liste vide si le fichier n’existe pas', () async {
    final loadedTasks = await storage.load();

    expect(loadedTasks, isEmpty);
  });

  test('retourne une liste vide si le fichier est vide', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}tasks.json',
    );

    await file.writeAsString('');

    final loadedTasks = await storage.load();

    expect(loadedTasks, isEmpty);
  });

  test('lance StorageException si le JSON est invalide', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}tasks.json',
    );

    await file.writeAsString('{ JSON invalide }');

    expect(
      () => storage.load(),
      throwsA(isA<StorageException>()),
    );
  });

  test('utilise low comme priorité par défaut si la priorité est inconnue',
      () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}tasks.json',
    );

    await file.writeAsString('''
[
  {
    "id": 5,
    "title": "Tâche avec priorité inconnue",
    "priority": "critical",
    "dueDate": null,
    "isCompleted": false,
    "type": "regular"
  }
]
''');

    final loadedTasks = await storage.load();

    expect(loadedTasks, hasLength(1));
    expect(loadedTasks.first.priority, Priority.low);
  });
}