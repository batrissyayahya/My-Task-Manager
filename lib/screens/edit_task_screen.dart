import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/firestore_service.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final FirestoreService firestoreService = FirestoreService();

  late TextEditingController titleController;
  late TextEditingController descriptionController;

  bool isLoading = false;

  late String selectedPriority;

  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.task.title);

    descriptionController = TextEditingController(
      text: widget.task.description,
    );

    // Support old & new priority values
    selectedPriority =
        {
          "High": "Important",
          "Medium": "Moderate",
          "Low": "Flexible",
        }[widget.task.priority] ??
        widget.task.priority;

    selectedDate = widget.task.dueDate.toDate();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> updateTask() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter task title")));
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter description")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await firestoreService.updateTask(
        id: widget.task.id!,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        priority: selectedPriority,
        dueDate: Timestamp.fromDate(selectedDate),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Task Updated Successfully!"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color priorityColor() {
    switch (selectedPriority) {
      case "Important":
        return Colors.red;

      case "Moderate":
        return Colors.orange;

      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Edit Task",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Card(
          elevation: 8,
          shadowColor: Colors.black12,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),

          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Task Title",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: titleController,

                  decoration: InputDecoration(
                    hintText: "Enter task title",

                    prefixIcon: const Icon(Icons.task_alt),

                    filled: true,
                    fillColor: Colors.grey.shade100,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Description",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: descriptionController,
                  maxLines: 4,

                  decoration: InputDecoration(
                    hintText: "Describe your task...",

                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 65),
                      child: Icon(Icons.description),
                    ),

                    filled: true,
                    fillColor: Colors.grey.shade100,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Priority",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedPriority,

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),

                  items: const [
                    DropdownMenuItem(
                      value: "Important",
                      child: Text("🔴 Important"),
                    ),

                    DropdownMenuItem(
                      value: "Moderate",
                      child: Text("🟡 Moderate"),
                    ),

                    DropdownMenuItem(
                      value: "Flexible",
                      child: Text("🟢 Flexible"),
                    ),
                  ],

                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                ),

                const SizedBox(height: 25),

                const Text(
                  "Due Date",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                InkWell(
                  onTap: pickDate,

                  borderRadius: BorderRadius.circular(15),

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: priorityColor()),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Text(
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        TextButton.icon(
                          onPressed: pickDate,
                          icon: const Icon(Icons.edit_calendar),
                          label: const Text("Change"),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : updateTask,

                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),

                    label: Text(
                      isLoading ? "Updating..." : "Update Task",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3A8DFF),
                      foregroundColor: Colors.white,
                      elevation: 5,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
