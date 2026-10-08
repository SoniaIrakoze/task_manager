import 'dart:io';
import 'package:task_manager/models/regular_task.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/urgent_task.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/task_service.dart';
import 'package:task_manager/storage/json_storage.dart';

Future<void> main() async {
  final repository = TaskRepository();

  final storage = JsonStorage('data/tasks.json');

  final service = TaskService(
    repository: repository,
    storage: storage,
  );

  await service.loadTasks();

  print('=================================');
  print('     GESTIONNAIRE DE TÂCHES');
  print('=================================');

  var running = true;

  while (running) {
    print('');
    print('1. Ajouter une tâche');
    print('2. Lister les tâches');
    print('3. Terminer une tâche');
    print('4. Supprimer une tâche');
    print('5. Trier les tâches');
    print('6. Quitter');

    stdout.write('Choisissez une option : ');

    final choice = stdin.readLineSync();

    try {
      switch (choice) {
        case '1':
          await addTask(service);
          break;

        case '2':
          await listTasks(service);
          break;

        case '3':
          await completeTask(service);
          break;

        case '4':
          await deleteTask(service);
          break;

        case '5':
          await sortTasks(service);
          break;

        case '6':
          running = false;
          print('Au revoir !');
          break;

        default:
          print('Option invalide.');
      }
    } catch (e) {
      print('Erreur : $e');
    }
  }
}

Future<void> addTask(TaskService service) async {
  print('');
  print('--- Ajouter une tâche ---');

  stdout.write('Titre : ');
  final title = stdin.readLineSync()?.trim() ?? '';

  if (title.isEmpty) {
    print('Le titre ne peut pas être vide.');
    return;
  }

  stdout.write('Priorité (low/medium/high) : ');
  final priorityInput = stdin.readLineSync()?.trim().toLowerCase();

  final priority = parsePriority(priorityInput);

  stdout.write('Date limite (YYYY-MM-DD, facultative) : ');
  final dateInput = stdin.readLineSync()?.trim();

  DateTime? dueDate;

  if (dateInput != null && dateInput.isNotEmpty) {
    dueDate = DateTime.tryParse(dateInput);

    if (dueDate == null) {
      print('Date invalide.');
      return;
    }
  }

  stdout.write('Tâche urgente ? (o/n) : ');
  final urgentInput = stdin.readLineSync()?.trim().toLowerCase();

  final tasks = await service.getAllTasks();

  final nextId = tasks.isEmpty
      ? 1
      : tasks.map((task) => task.id).reduce((a, b) => a > b ? a : b) + 1;

  final Task task;

  if (urgentInput == 'o' || urgentInput == 'oui') {
    task = UrgentTask(
      id: nextId,
      title: title,
      priority: Priority.high,
      dueDate: dueDate,
    );
  } else {
    task = RegularTask(
      id: nextId,
      title: title,
      priority: priority,
      dueDate: dueDate,
    );
  }

  await service.addTask(task);

  print('Tâche ajoutée avec succès !');
}

Priority parsePriority(String? value) {
  switch (value) {
    case 'high':
      return Priority.high;
    case 'medium':
      return Priority.medium;
    case 'low':
      return Priority.low;
    default:
      return Priority.medium;
  }
}

Future<void> listTasks(TaskService service) async {
  print('');
  print('--- Liste des tâches ---');

  final tasks = await service.getAllTasks();

  if (tasks.isEmpty) {
    print('Aucune tâche.');
    return;
  }

  for (final task in tasks) {
    print(
      '#${task.id} | '
      '${task.title} | '
      'Priorité: ${task.priority.name} | '
      'Statut: ${task.isCompleted ? "Terminée" : "En cours"}'
      '${task.dueDate != null ? " | Date: ${task.dueDate!.toIso8601String().split("T").first}" : ""}',
    );
  }
}

Future<void> completeTask(TaskService service) async {
  print('');
  print('--- Terminer une tâche ---');

  stdout.write('ID de la tâche : ');

  final id = int.tryParse(stdin.readLineSync() ?? '');

  if (id == null) {
    print('ID invalide.');
    return;
  }

  await service.completeTask(id);

  print('Tâche terminée avec succès !');
}

Future<void> deleteTask(TaskService service) async {
  print('');
  print('--- Supprimer une tâche ---');

  stdout.write('ID de la tâche : ');

  final id = int.tryParse(stdin.readLineSync() ?? '');

  if (id == null) {
    print('ID invalide.');
    return;
  }

  await service.deleteTask(id);

  print('Tâche supprimée avec succès !');
}

Future<void> sortTasks(TaskService service) async {
  print('');
  print('--- Trier les tâches ---');
  print('1. Par priorité');
  print('2. Par date');

  stdout.write('Choisissez : ');

  final choice = stdin.readLineSync();

  final List<Task> tasks;

  if (choice == '1') {
    tasks = await service.sortByPriority();
  } else if (choice == '2') {
    tasks = await service.sortByDate();
  } else {
    print('Option invalide.');
    return;
  }

  if (tasks.isEmpty) {
    print('Aucune tâche.');
    return;
  }

  for (final task in tasks) {
    print(
      '#${task.id} | '
      '${task.title} | '
      'Priorité: ${task.priority.name} | '
      'Date: ${task.dueDate?.toIso8601String().split("T").first ?? "-"}',
    );
  }
}