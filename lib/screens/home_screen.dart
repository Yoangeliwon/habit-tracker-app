import 'package:flutter/material.dart';
import 'add_habit_screen.dart';
import '../services/storage.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState(); // Made public for navigation shell access
}

class HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> habits = [];
  bool isLoading = true; // Topic 5: Loading state indicator

  @override
  void initState() {
    super.initState();
    loadData();
    fetchApiHabits();
  }

  // 🔹 Topic 4: Load habits from local storage
  void loadData() async {
    List saved = await StorageService.loadHabits();
    setState(() {
      habits = List<Map<String, dynamic>>.from(saved);
    });
  }

  // 🔹 Topic 5: Networking & API Integration
  Future<void> fetchApiHabits() async {
    try {
      final users = await ApiService.fetchUsers();

      // Topic 5: JSON parsing of fetched data
      List<Map<String, dynamic>> apiHabits = users.map((user) {
        return {
          "title": "Check in with ${user["name"]}",
          "done": false,
          "location": "System API" // Placeholder for non-manual entries
        };
      }).toList();

      setState(() {
        for (var habit in apiHabits) {
          // Avoid adding the same API data twice
          if (!habits.any((h) => h["title"] == habit["title"])) {
            habits.add(habit);
          }
        }
        isLoading = false;
      });

      StorageService.saveHabits(habits);
    } catch (e) {
      setState(() => isLoading = false);
      // Topic 2: Feedback component (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load community habits from API")),
      );
    }
  }

  // 🔹 Topic 3: State Management (Update)
  void toggleHabit(int index) {
    setState(() {
      habits[index]["done"] = !habits[index]["done"];
    });
    StorageService.saveHabits(habits);
  }

  // 🔹 Topic 3: Receiving data from Add Screen
  // Modified to handle Map (Name + Location)
  void addHabit(Map<String, dynamic> habitData) {
    setState(() {
      habits.insert(0, {
        "title": habitData["title"],
        "location": habitData["location"], // Topic 6: Device feature integration
        "done": false
      });
    });

    StorageService.saveHabits(habits);
  }

  // 🔹 Topic 3: Navigation (Push/Pop)
  void openAddHabitScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );

    // Topic 3: Handling data returned from another screen
    if (result != null && result is Map<String, dynamic>) {
      addHabit(result);
    }
  }

  // Logic for the Progress Bar
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
        title: const Text("HabitFlow"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchApiHabits,
          )
        ],
      ),
      body: Column(
        children: [
          // 🔹 HEADER (UI Design)
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
                const Text("Welcome Back!", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                const Text(
                  "Your Daily Progress",
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white30,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 10),
                Text("${(progress * 100).toInt()}% of habits completed", style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 LIST SECTION
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // Topic 5: Loading indicator
                : habits.isEmpty
                    ? const Center(child: Text("No habits yet. Tap + to add one!"))
                    : ListView.builder(
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              setState(() => habits.removeAt(index));
                              StorageService.saveHabits(habits);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                leading: Checkbox(
                                  value: habit["done"],
                                  onChanged: (_) => toggleHabit(index),
                                ),
                                title: Text(
                                  habit["title"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: habit["done"] ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                // Topic 6: Integration of device feature data (Location)
                                subtitle: Text(
                                  habit["location"] ?? "No location tagged",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // This button triggers the navigation requirement
      floatingActionButton: FloatingActionButton(
        onPressed: openAddHabitScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}