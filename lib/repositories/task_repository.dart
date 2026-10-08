import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import 'repository.dart';

class TaskRepository implements Repository<Task> {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAll() async {
    return List.unmodifiable(_tasks);
  }

  @override
  Future<Task?> getById(int id) async {
    for (final task in _tasks) {
      if (task.id == id) {
        return task;
      }
    }

    return null;
  }

  @override
  Future<void> add(Task item) async {
    if (item.title.trim().isEmpty) {
      throw InvalidTaskException(
        'Le titre de la tâche ne peut pas être vide.',
      );
    }

    final existingTask = await getById(item.id);

    if (existingTask != null) {
      throw InvalidTaskException(
        'Une tâche avec l\'ID ${item.id} existe déjà.',
      );
    }

    _tasks.add(item);
  }

  @override
  Future<void> update(Task item) async {
    final index = _tasks.indexWhere((task) => task.id == item.id);

    if (index == -1) {
      throw TaskNotFoundException(item.id);
    }

    _tasks[index] = item;
  }

  @override
  Future<void> delete(int id) async {
    final index = _tasks.indexWhere((task) => task.id == id);

    if (index == -1) {
      throw TaskNotFoundException(id);
    }

    _tasks.removeAt(index);
  }
}