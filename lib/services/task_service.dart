import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../storage/json_storage.dart';

class TaskService {
  final TaskRepository repository;
  final JsonStorage storage;

  TaskService({
    required this.repository,
    required this.storage,
  });

  Future<List<Task>> getAllTasks() async {
    return repository.getAll();
  }

  Future<void> addTask(Task task) async {
    await repository.add(task);
    await _save();
  }

  Future<void> completeTask(int id) async {
    final task = await repository.getById(id);

    if (task == null) {
      throw TaskNotFoundException(id);
    }

    task.complete();

    await repository.update(task);
    await _save();
  }

  Future<void> deleteTask(int id) async {
    await repository.delete(id);
    await _save();
  }

  Future<Task> getTaskById(int id) async {
    final task = await repository.getById(id);

    if (task == null) {
      throw TaskNotFoundException(id);
    }

    return task;
  }

  Future<List<Task>> sortByPriority() async {
    final tasks = await repository.getAll();

    final sortedTasks = [...tasks];

    sortedTasks.sort(
      (a, b) => b.priority.index.compareTo(a.priority.index),
    );

    return sortedTasks;
  }

  Future<List<Task>> sortByDate() async {
    final tasks = await repository.getAll();

    final sortedTasks = [...tasks];

    sortedTasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) {
        return 0;
      }

      if (a.dueDate == null) {
        return 1;
      }

      if (b.dueDate == null) {
        return -1;
      }

      return a.dueDate!.compareTo(b.dueDate!);
    });

    return sortedTasks;
  }

  Future<void> loadTasks() async {
    final tasks = await storage.load();

    for (final task in tasks) {
      try {
        await repository.add(task);
      } on InvalidTaskException {
        // Ignore les tâches invalides ou déjà chargées.
      }
    }
  }

  Future<void> _save() async {
    final tasks = await repository.getAll();
    await storage.save(tasks);
  }
}