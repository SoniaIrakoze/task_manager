class TaskNotFoundException implements Exception {
  final int taskId;

  TaskNotFoundException(this.taskId);

  @override
  String toString() {
    return 'Tâche $taskId introuvable.';
  }
}

class InvalidTaskException implements Exception {
  final String message;

  InvalidTaskException(this.message);

  @override
  String toString() {
    return message;
  }
}