import 'package:flutter/material.dart';
import 'add_habit_screen.dart';
import '../services/storage.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // ✅ FIXED

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> habits = [];
  bool isLoading = true; // 🔥 loading state

  @override
  void initState() {
    super.initState();
    loadData();
    fetchApiHabits(); // ✅ NOW USED → no unused import
  }

  // 🔹 Load habits from local storage
  void loadData() async {
    List saved = await StorageService.loadHabits();
    setState(() {
      habits = List<Map<String, dynamic>>.from(saved);
    });
  }

  // 🔥 Fetch from API
  Future<void> fetchApiHabits() async {
    try {
      final users = await ApiService.fetchUsers();

      List<Map<String, dynamic>> apiHabits = users.map((user) {
        return {
          "title": user["name"],
          "done": false,
        };
      }).toList();

      // ✅ Avoid duplicates
      setState(() {
        for (var habit in apiHabits) {
          if (!habits.any((h) => h["title"] == habit["title"])) {
            habits.add(habit);
          }
        }
        isLoading = false;
      });

      StorageService.saveHabits(habits);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load API data")),
      );
    }
  }

  // 🔹 Toggle habit
  void toggleHabit(int index) {
    setState(() {
      habits[index]["done"] = !habits[index]["done"];
    });
    StorageService.saveHabits(habits);
  }

  // 🔹 Add habit
  void addHabit(String habitName) {
    if (habitName.trim().isEmpty) return;

    setState(() {
      habits.add({"title": habitName, "done": false});
    });

    StorageService.saveHabits(habits);
  }

  // 🔹 Navigate
  void openAddHabitScreen() async {
    final newHabit = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );

    if (newHabit != null && newHabit is String) {
      addHabit(newHabit);
    }
  }

  // 🔹 Progress
  double getProgress() {
    if (habits.isEmpty) return 0;
    int completed = habits.where((h) => h["done"] == true).length;
    return completed / habits.length;
  }

  @override
  Widget build(BuildContext context) {
    double progress = getProgress();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        elevation: 0,
        title: const Text("Habit Tracker"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // 🔹 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hello 👋",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Track your daily habits",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white30,
                  color: Colors.greenAccent,
                ),

                const SizedBox(height: 5),

                Text(
                  "${(progress * 100).toInt()}% completed",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 LIST / LOADING
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // 🔥 loading
                : habits.isEmpty
                    ? const Center(
                        child: Text(
                          "No habits yet. Add one!",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            key: Key(
                                habits[index]["title"] + index.toString()),
                            direction: DismissDirection.endToStart,

                            // 🔥 DELETE
                            onDismissed: (direction) {
                              setState(() {
                                habits.removeAt(index);
                              });

                              StorageService.saveHabits(habits);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Habit deleted"),
                                ),
                              );
                            },

                            // 🔴 BACKGROUND
                            background: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 6),
                              padding: const EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),

                            // 🔹 CARD
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: habits[index]["done"],
                                  onChanged: (_) => toggleHabit(index),
                                ),
                                title: Text(
                                  habits[index]["title"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    decoration: habits[index]["done"]
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openAddHabitScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}