enum Priority {
  low,
  medium,
  high,
}

abstract class Task {
  final int id;
  String title;
  Priority priority;
  DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
  });

  void complete() {
    isCompleted = true;
  }

  Map<String, dynamic> toJson();

  @override
  String toString();
}