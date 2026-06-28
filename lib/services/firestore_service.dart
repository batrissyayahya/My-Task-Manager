import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // ===========================
  // CREATE
  // ===========================

  Future<void> addTask({
    required String title,
    required String description,
    required String priority,
    required Timestamp dueDate,
  }) async {
    TaskModel task = TaskModel(
      title: title,
      description: description,
      priority: priority,
      createdAt: Timestamp.now(),
      dueDate: dueDate,
      isCompleted: false,
      uid: uid,
    );

    await _db.collection("tasks").add(task.toMap());
  }

  // ===========================
  // READ
  // ===========================

  Stream<List<TaskModel>> getTasks() {
    return _db
        .collection("tasks")
        .where("uid", isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ===========================
  // UPDATE TASK
  // ===========================

  Future<void> updateTask({
    required String id,
    required String title,
    required String description,
    required String priority,
    required Timestamp dueDate,
  }) async {
    await _db.collection("tasks").doc(id).update({
      "title": title,
      "description": description,
      "priority": priority,
      "dueDate": dueDate,
    });
  }

  // ===========================
  // COMPLETE TASK
  // ===========================

  Future<void> updateTaskStatus(String id, bool isCompleted) async {
    await _db.collection("tasks").doc(id).update({"isCompleted": isCompleted});
  }

  // ===========================
  // DELETE
  // ===========================

  Future<void> deleteTask(String id) async {
    await _db.collection("tasks").doc(id).delete();
  }
}
