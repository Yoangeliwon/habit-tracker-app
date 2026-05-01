import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // Topic 6: Permissions
import 'home_screen.dart';
import 'add_habit_screen.dart';
import '../services/storage.dart';
import '../services/api_service.dart';

class MainNavigation extends StatefulWidget {
  final Function(bool) onThemeChanged; // Topic 3: State management callback
  const MainNavigation({super.key, required this.onThemeChanged});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> habits = [];
  bool isLoading = true;

  // Settings State
  bool remindersEnabled = false;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Topic 4: Data Persistence Initialization
  void _loadAllData() async {
    final saved = await StorageService.loadHabits();
    setState(() {
      habits = List<Map<String, dynamic>>.from(saved);
    });
    _fetchApi();
  }

  // Topic 5: Networking & API Integration
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

  // Topic 6: Handle Permission for Reminders
  Future<void> _toggleReminders(bool value) async {
    if (value) {
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        setState(() => remindersEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reminders Enabled Successfully"))
        );
      } else {
        setState(() => remindersEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification Permission Denied"))
        );
      }
    } else {
      setState(() => remindersEnabled = false);
    }
  }


  void _addHabit(Map<String, dynamic> data) {
    // 1. Get the current time automatically
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final amPm = now.hour >= 12 ? "PM" : "AM";
    final timeString = "$hour:${now.minute.toString().padLeft(2, '0')} $amPm";

    setState(() {
      // 2. Add the time to the data map
      data['time'] = timeString;

      // 3. Add to the list
      habits.insert(0, data);
    });

    // 4. Save to local storage (Topic 4)
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
      // SCREEN 1: HOME
      HomeScreen(
        habits: habits,
        isLoading: isLoading,
        onToggle: _toggleHabit,
        onDelete: _deleteHabit,
        onRefresh: _fetchApi,
      ),
      // SCREEN 2: STATS
      StatsScreen(habits: habits),
      // SCREEN 3: SETTINGS
      SettingsScreen(
        reminders: remindersEnabled,
        darkMode: isDarkMode,
        onReminderChanged: _toggleReminders,
        onDarkModeChanged: (bool value) {
          setState(() => isDarkMode = value);
          widget.onThemeChanged(value);
        },
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

// --- STATS SCREEN ---
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
            Text("Completed ${percent.toInt()}% of habits!"),
            Text("$completed done / $total total"),
          ],
        ),
      ),
    );
  }
}

// --- SETTINGS SCREEN ---
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
            leading: Icon(Icons.info_outline),
            title: Text("App Version"),
            subtitle: Text("1.0.0"),
          ),
        ],
      ),
    );
  }
}
