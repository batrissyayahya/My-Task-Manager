import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();

  final AuthService authService = AuthService();

  final TextEditingController searchController = TextEditingController();

  String sortBy = "Latest";
  String greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    final username =
        FirebaseAuth.instance.currentUser?.email?.split('@').first ?? "User";

    final displayName = username.isNotEmpty
        ? username[0].toUpperCase() + username.substring(1)
        : "User";

    return StreamBuilder<List<TaskModel>>(
      stream: firestoreService.getTasks(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final allTasks = snapshot.data ?? [];

        List<TaskModel> tasks = List.from(allTasks);

        // SEARCH

        if (searchController.text.isNotEmpty) {
          tasks = tasks.where((task) {
            return task.title.toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
          }).toList();
        }

        // SORTING

        // LATEST
        if (sortBy == "Latest") {
          tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }

        // OLDEST
        if (sortBy == "Oldest") {
          tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }

        // PRIORITY
        if (sortBy == "Priority") {
          const priority = {"Important": 1, "Moderate": 2, "Flexible": 3};

          tasks.sort(
            (a, b) => priority[a.priority]!.compareTo(priority[b.priority]!),
          );
        }

        // DUE DATE
        if (sortBy == "Due Date") {
          tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        }
        int total = allTasks.length;

        int completed = allTasks.where((e) => e.isCompleted).length;

        int pending = total - completed;

        // Progress Percentage
        double progress = 0;

        if (total > 0) {
          progress = completed / total;
        }

        // Progress Message
        String progressMessage;

        if (progress == 1) {
          progressMessage = "🎉 Amazing! All tasks completed.";
        } else if (progress >= 0.7) {
          progressMessage = "🔥 Great job! Keep it up.";
        } else if (progress >= 0.4) {
          progressMessage = "💪 You're making good progress.";
        } else if (progress > 0) {
          progressMessage = "🚀 Keep going!";
        } else {
          progressMessage = "Let's start completing tasks!";
        }

        return Scaffold(
          backgroundColor: const Color(0xffF5F7FB),

          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xff3A8DFF),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "New Task",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTaskScreen()),
              );
            },
          ),

          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              //=========================
              // HEADER
              //=========================
              Container(
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 24,
                  right: 24,
                  bottom: 35,
                ),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff3A8DFF), Color(0xff6C4BFF)],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),

                    bottomRight: Radius.circular(35),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${greeting()}, $displayName 👋",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  "Stay productive today!",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        PopupMenuButton(
                          onSelected: (value) async {
                            if (value == "logout") {
                              await authService.logout();

                              if (!mounted) return;

                              Navigator.pushReplacement(
                                context,

                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            }
                          },

                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: "logout",

                              child: Text("Logout"),
                            ),
                          ],

                          child: const CircleAvatar(
                            radius: 28,

                            backgroundColor: Colors.white,

                            child: Icon(Icons.person, color: Color(0xff3A8DFF)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: statCard(
                            Icons.list_alt,

                            "Total",

                            total.toString(),

                            Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: statCard(
                            Icons.check_circle,

                            "Completed",

                            completed.toString(),

                            Colors.green,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: statCard(
                            Icons.schedule,

                            "Pending",

                            pending.toString(),

                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            color: Color(0xff3A8DFF),
                          ),

                          SizedBox(width: 8),

                          Text(
                            "Today's Progress",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),

                          duration: const Duration(milliseconds: 700),

                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 12,

                              backgroundColor: Colors.grey.shade300,

                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xff3A8DFF),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            "$completed of $total tasks completed",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          Text(
                            "${(progress * 100).toInt()}%",
                            style: const TextStyle(
                              color: Color(0xff3A8DFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        progressMessage,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //=========================
              // SEARCH BAR
              //=========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: TextField(
                  controller: searchController,

                  onChanged: (value) {
                    setState(() {});
                  },

                  decoration: InputDecoration(
                    hintText: "Search your tasks...",

                    prefixIcon: const Icon(Icons.search),

                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),

                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              //=========================
              // SORT
              //=========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Row(
                  children: [
                    const Text(
                      "Sort By",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: DropdownButton<String>(
                        value: sortBy,

                        underline: const SizedBox(),

                        items: const [
                          DropdownMenuItem(
                            value: "Latest",
                            child: Text("Latest"),
                          ),

                          DropdownMenuItem(
                            value: "Oldest",
                            child: Text("Oldest"),
                          ),

                          DropdownMenuItem(
                            value: "Priority",
                            child: Text("Priority"),
                          ),

                          DropdownMenuItem(
                            value: "Due Date",
                            child: Text("Due Date"),
                          ),
                        ],

                        onChanged: (value) {
                          setState(() {
                            sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //=========================
              // EMPTY STATE
              //=========================
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),

                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 110,
                        color: Colors.grey.shade400,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "No Tasks Yet",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Tap the + button to create your first task.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: tasks.length,

                  itemBuilder: (context, index) {
                    return taskCard(tasks[index]);
                  },
                ),

              const SizedBox(height: 120),
            ],
          ),
        );
      },
    );
  }
  //=========================================================
  // STAT CARD
  //=========================================================

  Widget statCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(.15),

            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),

          const SizedBox(height: 3),

          Text(title, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  //=========================================================
  // TASK CARD
  //=========================================================

  Widget taskCard(TaskModel task) {
    Color priorityColor;

    switch (task.priority) {
      case "Important":
        priorityColor = Colors.red;
        break;

      case "Moderate":
        priorityColor = Colors.orange;
        break;

      default:
        priorityColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            //=================================
            // CHECKBOX
            //=================================
            GestureDetector(
              onTap: () async {
                await firestoreService.updateTaskStatus(
                  task.id!,

                  !task.isCompleted,
                );
              },

              child: CircleAvatar(
                radius: 18,

                backgroundColor: task.isCompleted
                    ? Colors.green
                    : Colors.grey.shade300,

                child: Icon(
                  Icons.check,

                  color: task.isCompleted ? Colors.white : Colors.grey,
                ),
              ),
            ),

            const SizedBox(width: 15),

            //=================================
            // CONTENT
            //=================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    task.title,

                    style: TextStyle(
                      fontSize: 19,

                      fontWeight: FontWeight.bold,

                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    task.description,

                    style: TextStyle(
                      color: Colors.grey.shade700,

                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 10,

                    runSpacing: 8,

                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,

                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(.15),

                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Text(
                          task.priority,

                          style: TextStyle(
                            color: priorityColor,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,

                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(.12),

                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.blue,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              "${task.dueDate.toDate().day}/${task.dueDate.toDate().month}/${task.dueDate.toDate().year}",

                              style: const TextStyle(
                                color: Colors.blue,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //=================================
            // POPUP MENU
            //=================================
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == "edit") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTaskScreen(task: task),
                    ),
                  );
                }

                if (value == "delete") {
                  bool? confirm = await showDialog<bool>(
                    context: context,

                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        title: const Text("Delete Task"),

                        content: Text(
                          "Are you sure you want to delete '${task.title}' ?",
                        ),

                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },

                            child: const Text("Cancel"),
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),

                            onPressed: () {
                              Navigator.pop(context, true);
                            },

                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await firestoreService.deleteTask(task.id!);

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,

                        behavior: SnackBarBehavior.floating,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),

                            SizedBox(width: 10),

                            Text("Task deleted successfully!"),
                          ],
                        ),
                      ),
                    );
                  }
                }
              },

              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: "edit",

                  child: Row(
                    children: [
                      Icon(Icons.edit),

                      SizedBox(width: 10),

                      Text("Edit"),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: "delete",

                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),

                      SizedBox(width: 10),

                      Text("Delete", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
