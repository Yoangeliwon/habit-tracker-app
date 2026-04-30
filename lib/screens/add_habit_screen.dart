
          TextField(
            controller: _habitController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Habit Name",
              hintText: "e.g., Drink Water",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
            ),
          ),
          const SizedBox(height: 15),
          
          // Topic 6: UI Integration for Device Feature
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: _isGettingLocation 
                  ? const CircularProgressIndicator(strokeWidth: 2) 
                  : const Icon(Icons.location_on, color: Colors.blue),
              title: Text(
                _locationStatus,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: const Text("Tag current location"),
              trailing: IconButton(
                icon: const Icon(Icons.gps_fixed),
                onPressed: _isGettingLocation ? null : _getLocation,
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _saveHabit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Save Habit", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
 import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Topic 6: Plugin Integration

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  // Topic 2: Use of controller for Form/Input field
  final TextEditingController _habitController = TextEditingController();
  String _locationStatus = "Location not attached";
  bool _isGettingLocation = false;

  @override
  void dispose() {
    // Best practice: Clean up controller when screen is closed
    _habitController.dispose();
    super.dispose();
  }

  // Topic 6: Accessing Device Feature (Location) & Handling Permissions
  Future<void> _getLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      // Topic 6: Properly handle permission requests
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showFeedback("Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showFeedback("Location permissions are permanently denied. Please enable in settings.");
        return;
      }

      // If permissions are granted, get the coordinates
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _locationStatus = "Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)}";
      });
      _showFeedback("Location successfully tagged!");
      
    } catch (e) {
      _showFeedback("Error getting location: $e");
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  // Topic 2: Feedback component (Snackbar)
  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Topic 3: Navigation & Data Passing
  void _saveHabit() {
    final habitName = _habitController.text.trim();

    if (habitName.isEmpty) {
      _showFeedback("Please enter a habit name");
      return;
    }

    // Topic 3: Passing data back to HomeScreen (Pop)
    Navigator.pop(context, {
      "title": habitName,
      "location": _locationStatus,
      "done": false
    });
  }

  @override
  Widget build(BuildContext context) {
    // UI logic: Adjust padding for the keyboard when used as a BottomSheet
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
        top: 20, 
        left: 20, 
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Topic 2: Proper layout structure
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Create New Habit",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
// Topic 2: Form/Input field
          TextField(
            controller: _habitController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Habit Name",
              hintText: "e.g., Drink Water",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
            ),
          ),
          const SizedBox(height: 15),
          
          // Topic 6: UI Integration for Device Feature
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: _isGettingLocation 
                  ? const CircularProgressIndicator(strokeWidth: 2) 
                  : const Icon(Icons.location_on, color: Colors.blue),
              title: Text(
                _locationStatus,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: const Text("Tag current location"),
              trailing: IconButton(
                icon: const Icon(Icons.gps_fixed),
                onPressed: _isGettingLocation ? null : _getLocation,
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _saveHabit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Save Habit", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}