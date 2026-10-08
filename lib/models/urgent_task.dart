import 'task.dart';

class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    super.priority = Priority.high,
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
      'type': 'urgent',
    };
  }

  @override
  String toString() {
    final status = isCompleted ? 'Terminée' : 'En cours';
    final date = dueDate != null
        ? ' - Échéance : ${dueDate!.toLocal()}'
        : '';

    return '[$status] $title | Priorité : ${priority.name}$date';
  }
}