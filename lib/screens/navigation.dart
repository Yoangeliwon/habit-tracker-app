import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_habit_screen.dart';
import '../services/storage.dart';
import '../services/api_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> habits = [];
  bool isLoading = true;

  // Settings State
  bool remindersEnabled = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() async {
    final saved = await StorageService.loadHabits();
    setState(() {
      habits = List<Map<String, dynamic>>.from(saved);
    });
    _fetchApi();
  }

  void _fetchApi() async {
    try {
      final users = await ApiService.fetchUsers();
      setState(() {
        for (var user in users) {
          String title = "Check in with ${user["name"]}";
          if (!habits.any((h) => h["title"] == title)) {
            habits.add({"title": title, "done": false, "location": "API Source"});
          }
        }
        isLoading = false;
      });
      StorageService.saveHabits(habits);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _addHabit(Map<String, dynamic> data) {
    setState(() {
      habits.insert(0, data);
    });
    StorageService.saveHabits(habits);
  }

  void _toggleHabit(int index) {
    setState(() {
      habits[index]["done"] = !habits[index]["done"];
    });
    StorageService.saveHabits(habits);
  }

  void _deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
    StorageService.saveHabits(habits);
  }

  void _openAddModal() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddHabitScreen(),
    );
    if (result != null) _addHabit(result);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        habits: habits,
        isLoading: isLoading,
        onToggle: _toggleHabit,
        onDelete: _deleteHabit,
        onRefresh: _fetchApi,
      ),
      StatsScreen(habits: habits), // Pass habits to Stats
      SettingsScreen(
        reminders: remindersEnabled,
        darkMode: isDarkMode,
        onReminderChanged: (v) => setState(() => remindersEnabled = v),
        onDarkModeChanged: (v) => setState(() => isDarkMode = v),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- FIXED STATS SCREEN (Topic 3: Structured Approach) ---
class StatsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  const StatsScreen({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    int total = habits.length;
    int completed = habits.where((h) => h["done"] == true).length;
    double percent = total == 0 ? 0 : (completed / total) * 100;
    return Scaffold(
      appBar: AppBar(title: const Text("Statistics")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visual Pie Chart placeholder
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150, width: 150,
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 15,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                Text("${percent.toInt()}%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "You have completed ${percent.toInt()}% of your goals!",
              style: const TextStyle(fontSize: 18),
            ),
            Text("$completed of $total habits done"),
          ],
        ),
      ),
    );
  }
}

// --- FIXED SETTINGS SCREEN (Topic 2: Meaningful Interaction) ---
class SettingsScreen extends StatelessWidget {
  final bool reminders;
  final bool darkMode;
  final Function(bool) onReminderChanged;
  final Function(bool) onDarkModeChanged;

  const SettingsScreen({
    super.key,
    required this.reminders,
    required this.darkMode,
    required this.onReminderChanged,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Reminders"),
            secondary: const Icon(Icons.notifications),
            value: reminders,
            onChanged: onReminderChanged,
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: const Icon(Icons.dark_mode),
            value: darkMode,
            onChanged: onDarkModeChanged,
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text("App Version"),
            subtitle: Text("1.0.0"),
          ),
        ],
      ),
    );
  }
}
