import 'dart:io';

import 'package:task_manager/exceptions/task_exceptions.dart';
import 'package:task_manager/models/regular_task.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/urgent_task.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/task_service.dart';
import 'package:task_manager/storage/json_storage.dart';
import 'package:test/test.dart';

void main() {
  late TaskRepository repository;
  late JsonStorage storage;
  late TaskService service;
  late Directory tempDirectory;

  setUp(() async {
    repository = TaskRepository();

    tempDirectory = await Directory.systemTemp.createTemp(
      'task_manager_service_test_',
    );

    storage = JsonStorage(
      '${tempDirectory.path}${Platform.pathSeparator}tasks.json',
    );

    service = TaskService(
      repository: repository,
      storage: storage,
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('ajoute une tâche et la sauvegarde', () async {
    final task = RegularTask(
      id: 1,
      title: 'Faire le rapport',
      priority: Priority.medium,
    );

    await service.addTask(task);

    final tasks = await service.getAllTasks();

    expect(tasks, hasLength(1));
    expect(tasks.first.title, 'Faire le rapport');

    final loadedTasks = await storage.load();

    expect(loadedTasks, hasLength(1));
    expect(loadedTasks.first.title, 'Faire le rapport');
  });

  test('récupère une tâche par son ID', () async {
    final task = RegularTask(
      id: 1,
      title: 'Préparer le rapport',
      priority: Priority.high,
    );

    await service.addTask(task);

    final result = await service.getTaskById(1);

    expect(result.id, 1);
    expect(result.title, 'Préparer le rapport');
  });

  test('lance une exception si la tâche demandée est inexistante', () async {
    expect(
      () => service.getTaskById(999),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('termine une tâche et sauvegarde son statut', () async {
    final task = RegularTask(
      id: 1,
      title: 'Faire le rapport',
      priority: Priority.medium,
    );

    await service.addTask(task);
    await service.completeTask(1);

    final result = await service.getTaskById(1);

    expect(result.isCompleted, isTrue);

    final loadedTasks = await storage.load();

    expect(loadedTasks.first.isCompleted, isTrue);
  });

  test('lance une exception si on termine une tâche inexistante', () async {
    expect(
      () => service.completeTask(999),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('supprime une tâche et sauvegarde la suppression', () async {
    final task = RegularTask(
      id: 1,
      title: 'Tâche à supprimer',
      priority: Priority.low,
    );

    await service.addTask(task);
    await service.deleteTask(1);

    final tasks = await service.getAllTasks();

    expect(tasks, isEmpty);

    final loadedTasks = await storage.load();

    expect(loadedTasks, isEmpty);
  });

  test('trie les tâches par priorité', () async {
    await service.addTask(
      RegularTask(
        id: 1,
        title: 'Tâche basse',
        priority: Priority.low,
      ),
    );

    await service.addTask(
      RegularTask(
        id: 2,
        title: 'Tâche haute',
        priority: Priority.high,
      ),
    );

    await service.addTask(
      RegularTask(
        id: 3,
        title: 'Tâche moyenne',
        priority: Priority.medium,
      ),
    );

    final tasks = await service.sortByPriority();

    expect(tasks.map((task) => task.priority).toList(), [
      Priority.high,
      Priority.medium,
      Priority.low,
    ]);
  });

  test('trie les tâches par date', () async {
    await service.addTask(
      RegularTask(
        id: 1,
        title: 'Tâche tardive',
        priority: Priority.low,
        dueDate: DateTime(2026, 10, 20),
      ),
    );

    await service.addTask(
      RegularTask(
        id: 2,
        title: 'Tâche urgente',
        priority: Priority.high,
        dueDate: DateTime(2026, 10, 10),
      ),
    );

    final tasks = await service.sortByDate();

    expect(tasks.map((task) => task.id).toList(), [2, 1]);
  });

  test('place les tâches sans date à la fin lors du tri par date', () async {
    await service.addTask(
      RegularTask(
        id: 1,
        title: 'Sans date',
        priority: Priority.low,
      ),
    );

    await service.addTask(
      RegularTask(
        id: 2,
        title: 'Avec date',
        priority: Priority.high,
        dueDate: DateTime(2026, 10, 10),
      ),
    );

    final tasks = await service.sortByDate();

    expect(tasks.map((task) => task.id).toList(), [2, 1]);
  });

  test('charge les tâches sauvegardées depuis le JSON', () async {
    final urgentTask = UrgentTask(
      id: 1,
      title: 'Préparer la présentation',
      priority: Priority.high,
      dueDate: DateTime(2026, 10, 20),
    );

    await storage.save([urgentTask]);

    final newRepository = TaskRepository();

    final newService = TaskService(
      repository: newRepository,
      storage: storage,
    );

    await newService.loadTasks();

    final tasks = await newService.getAllTasks();

    expect(tasks, hasLength(1));
    expect(tasks.first, isA<UrgentTask>());
    expect(tasks.first.title, 'Préparer la présentation');
    expect(tasks.first.priority, Priority.high);
  });

  test('conserve une tâche terminée lors du chargement JSON', () async {
    final task = RegularTask(
      id: 1,
      title: 'Tâche terminée',
      priority: Priority.medium,
      isCompleted: true,
    );

    await storage.save([task]);

    final newRepository = TaskRepository();

    final newService = TaskService(
      repository: newRepository,
      storage: storage,
    );

    await newService.loadTasks();

    final loadedTask = await newService.getTaskById(1);

    expect(loadedTask.isCompleted, isTrue);
  });
}