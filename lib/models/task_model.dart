import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String? id;
  String title;
  String description;

  String priority;

  Timestamp createdAt;

  Timestamp dueDate;

  bool isCompleted;

  String uid;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
    required this.dueDate,
    required this.isCompleted,
    required this.uid,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String documentId) {
    return TaskModel(
      id: documentId,

      title: data["title"] ?? "",

      description: data["description"] ?? "",

      priority: data["priority"] ?? "Moderate",

      createdAt: data["createdAt"] ?? Timestamp.now(),

      dueDate: data["dueDate"] ?? Timestamp.now(),

      isCompleted: data["isCompleted"] ?? false,

      uid: data["uid"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,

      "description": description,

      "priority": priority,

      "createdAt": createdAt,

      "dueDate": dueDate,

      "isCompleted": isCompleted,

      "uid": uid,
    };
  }
}
