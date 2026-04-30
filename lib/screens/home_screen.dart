import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // Data and functions passed from MainNavigation
  final List<Map<String, dynamic>> habits;
  final bool isLoading;
  final Function(int) onToggle;
  final Function(int) onDelete;
  final VoidCallback onRefresh;

  const HomeScreen({
    super.key,
    required this.habits,
    required this.isLoading,
    required this.onToggle,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Logic for the Progress Bar (Topic 2 & 3)
    int completedCount = habits.where((h) => h["done"] == true).length;
    double progress = habits.isEmpty ? 0 : completedCount / habits.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text("HabitFlow"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh, // Topic 5: Manual API refresh
          )
        ],
      ),
      body: Column(
        children: [
          // 🔹 BEAUTIFUL HEADER (From your original UI)
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
                  style: TextStyle(
                    fontSize: 20, 
                    color: Colors.white, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white30,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 10),
                Text(
                  "${(progress * 100).toInt()}% of habits completed", 
                  style: const TextStyle(color: Colors.white)
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 HABIT LIST SECTION
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
                            onDismissed: (_) => onDelete(index), // Topic 3: State Update
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: habit["done"],
                                  onChanged: (_) => onToggle(index), // Topic 3: Update State
                                ),
                                title: Text(
                                  habit["title"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: habit["done"] 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                  ),
                                ),
                                // Topic 6: Display device feature data (Location)
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
    );
  }
}