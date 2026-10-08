import 'task.dart';

class RegularTask extends Task {
  RegularTask({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.isCompleted = false,
  });

  @override
  String get type => 'regular';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'type': type,
    };
  }

  @override
  String toString() {
    final status = isCompleted ? 'Terminée' : 'En cours';

    return '[$status] $title | Priorité : ${priority.name}';
  }
}