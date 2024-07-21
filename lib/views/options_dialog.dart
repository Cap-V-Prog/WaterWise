import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waterwize/views/register_page.dart';
import 'home_page.dart';
import 'package:waterwize/widgets/widgets.dart';

class OptionsDialog extends StatefulWidget {
  @override
  _OptionsDialogState createState() => _OptionsDialogState();
}

class _OptionsDialogState extends State<OptionsDialog> {
  final _goalController = TextEditingController();
  double _currentGoal = 3.0;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentGoalAndProgress();
  }

  Future<void> _loadCurrentGoalAndProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            _currentGoal = data['dailyGoal'] ?? 3.0;
            _currentProgress = data['progress'] ?? 0.0;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _saveDailyGoal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newGoal = double.tryParse(_goalController.text) ?? _currentGoal;
      final newProgress = _currentProgress * (_currentGoal / newGoal);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'dailyGoal': newGoal,
        'progress': newProgress,
      }, SetOptions(merge: true));

      // Call a function to update the UI in the HomeScreen
      Navigator.of(context).pop(newGoal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Daily Goal'),
      content: TextField(
        controller: _goalController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: "Enter daily goal in liters"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await _saveDailyGoal();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
