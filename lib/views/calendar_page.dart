import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  Map<DateTime, Map<String, dynamic>> _dailyRecords = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _loadDailyRecords();
  }

  Future<void> _loadDailyRecords() async {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dailyRecords')
          .where('date', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('date', isLessThanOrEqualTo: lastDayOfMonth)
          .get();

      final records = snapshot.docs.map((doc) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        return MapEntry(date, {
          'waterIntake': data['waterIntake'] ?? 0.0,
          'goal': data['goal'] ?? 3.0,
        });
      });

      setState(() {
        _dailyRecords = Map.fromEntries(records);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monthly Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showDailyRecordDialog(selectedDay);
            },
            calendarFormat: CalendarFormat.month,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _dailyRecords.keys.length,
              itemBuilder: (context, index) {
                final date = _dailyRecords.keys.elementAt(index);
                final record = _dailyRecords[date]!;
                return ListTile(
                  title: Text(formatDate(date)),
                  subtitle: Text(
                      'Water Intake: ${record['waterIntake']} L, Goal: ${record['goal']} L'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDailyRecordDialog(DateTime date) async {
    final record = _dailyRecords[date] ?? {'waterIntake': 0.0, 'goal': 3.0};

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Daily Record for ${formatDate(date)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Water Intake: ${record['waterIntake']} L'),
              Text('Goal: ${record['goal']} L'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    return '$day/$month/$year'; // Adjust format as needed
  }
}
