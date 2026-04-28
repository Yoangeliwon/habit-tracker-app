import 'package:flutter/material.dart';

// AddHabitScreen – Member 2: Add Habit (Form + Interaction)
// This screen allows the user to type a new habit and save it.
// It returns the habit name back to HomeScreen via Navigator.pop().

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  // Controller to read the text the user types in the TextField
  final TextEditingController _habitController = TextEditingController();

  // Called when the user taps "Save Habit"
  // [USER INTERACTION] – button tap triggers this method
  void _saveHabit() {
    final String habitName = _habitController.text.trim();

    // [VALIDATION] – check if the input is empty
    if (habitName.isEmpty) {
      // [SNACKBAR] – show error message when input is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit')),
      );
      return;
    }

    // [DATA RETURN] – send the habit name back to HomeScreen
    Navigator.pop(context, habitName);
  }

  @override
  void dispose() {
    // Free the controller from memory when the screen is closed
    _habitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your new habit below:',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 16),

            // TextField where the user types the habit name
            TextField(
              controller: _habitController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                hintText: 'e.g. Drink 8 glasses of water',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // Save button – triggers _saveHabit() on tap
            ElevatedButton(
              onPressed: _saveHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save Habit', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
