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

  Future<void> _saveDailyRecord(DateTime date, double waterIntake, double goal) async {
    final user = _auth.currentUser;
    if (user != null) {
      final recordData = {
        'date': date,
        'waterIntake': waterIntake,
        'goal': goal,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dailyRecords')
          .doc(date.toIso8601String())
          .set(recordData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendário mensal')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getDailyRecordsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            _dailyRecords = Map.fromEntries(docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              return MapEntry(date, {
                'waterIntake': data['waterIntake'] ?? 0.0,
                'goal': data['goal'] ?? 3.0,
              });
            }));
          }

          return Column(
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
                eventLoader: (day) {
                  return _dailyRecords[day] != null ? [Container()] : [];
                },
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
                          'Água Bebida: ${record['waterIntake']} L\nObjetivo: ${record['goal']} L'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getDailyRecordsStream() {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dailyRecords')
          .where('date', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('date', isLessThanOrEqualTo: lastDayOfMonth)
          .snapshots();
    } else {
      return Stream.empty();
    }
  }

  Future<void> _showDailyRecordDialog(DateTime date) async {
    final record = _dailyRecords[date] ?? {'waterIntake': 0.0, 'goal': 3.0};
    final TextEditingController waterIntakeController = TextEditingController(text: record['waterIntake'].toString());
    final TextEditingController goalController = TextEditingController(text: record['goal'].toString());

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Objetivo diário para ${formatDate(date)}',style: const TextStyle(color: Color(0xFF5B8ADB)),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: waterIntakeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: const Color(0xFF5B8ADB),
                    filled: true,
                    hintText: 'Água Bebida (L)',
                    hintStyle: const TextStyle(color: Colors.white),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              Container(height: 10,),
              TextField(
                controller: goalController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: const Color(0xFF5B8ADB),
                  filled: true,
                  hintText: 'Objetivo (L)',
                  hintStyle: const TextStyle(color: Colors.white),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [

            SizedBox(
              width: 115,
              height: 34,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(

                  backgroundColor: Color(0xFF5B8ADB),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  double waterIntake = double.parse(waterIntakeController.text);
                  double goal = double.parse(goalController.text);
                  await _saveDailyRecord(date, waterIntake, goal);
                  setState(() {
                    _dailyRecords[date] =
                    {'waterIntake': waterIntake, 'goal': goal};
                  });
                },
                child: const Text(
                  'Guardar',
                  style: TextStyle(fontSize: 12.5, color: Colors.white),
                ),
              ),
            ),

            SizedBox(
              width: 115,
              height: 34,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 12.5, color: Colors.white),
                ),
              ),
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
