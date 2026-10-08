import 'dart:convert';
import 'dart:io';

import '../models/regular_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';

class JsonStorage {
  final String filePath;

  JsonStorage(this.filePath);

  Future<void> save(List<Task> tasks) async {
    try {
      final file = File(filePath);

      final directory = file.parent;

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final jsonData = tasks.map((task) => task.toJson()).toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      await file.writeAsString(jsonString);
    } catch (e) {
      throw StorageException(
        'Impossible de sauvegarder les tâches : $e',
      );
    }
  }

  Future<List<Task>> load() async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();

      if (jsonString.trim().isEmpty) {
        return [];
      }

      final List<dynamic> jsonData = jsonDecode(jsonString);

      return jsonData.map((json) {
        final data = json as Map<String, dynamic>;

        final priority = Priority.values.firstWhere(
          (value) => value.name == data['priority'],
          orElse: () => Priority.low,
        );

        final dueDate = data['dueDate'] != null
            ? DateTime.parse(data['dueDate'] as String)
            : null;

        final isUrgent = data['type'] == 'urgent';

        if (isUrgent) {
          return UrgentTask(
            id: data['id'] as int,
            title: data['title'] as String,
            priority: priority,
            dueDate: dueDate,
            isCompleted: data['isCompleted'] as bool? ?? false,
          );
        }

        return RegularTask(
          id: data['id'] as int,
          title: data['title'] as String,
          priority: priority,
          dueDate: dueDate,
          isCompleted: data['isCompleted'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }

      throw StorageException(
        'Impossible de charger les tâches : $e',
      );
    }
  }
}

class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => message;
}