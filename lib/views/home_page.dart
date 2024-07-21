import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _progress = 0; // Initially 0% progress
  double _dailyGoal = 3.0; // Default daily goal
  DateTime? _lastUpdatedDate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _loadDailyGoal();
  }

  Future<void> _loadProgress() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            final lastUpdatedTimestamp = data['lastUpdated'] as Timestamp?;
            final lastUpdatedDate = lastUpdatedTimestamp?.toDate();
            if (lastUpdatedDate != null && !_isSameDay(lastUpdatedDate, DateTime.now())) {
              setState(() {
                _progress = 0;
              });
            } else {
              setState(() {
                _progress = data['progress'] ?? 0;
              });
            }
            _lastUpdatedDate = lastUpdatedDate;
          }
        }
      }
    } catch (e) {
      // Handle any errors here
    }
  }

  Future<void> _loadDailyGoal() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            setState(() {
              _dailyGoal = data['dailyGoal'] ?? 3.0;
            });
          }
        }
      }
    } catch (e) {
      // Handle any errors here
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Future<void> _increaseProgress(double amount) async {
    setState(() {
      _progress = min(1.0, _progress + amount / _dailyGoal); // Adjust based on daily goal
    });

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'progress': _progress,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));
    }
  }

  void _showAddWaterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddWaterDialog(
          onIncreaseProgress: _increaseProgress,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 210,
        height: 600,
        child: ProgressBar(
          progress: _progress,
          dailyGoal: _dailyGoal,
          onShowAddWaterDialog: _showAddWaterDialog,
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double progress; // Progress value between 0 and 1
  final double dailyGoal; // Daily goal value
  final VoidCallback onShowAddWaterDialog;

  const ProgressBar({super.key, required this.progress, required this.dailyGoal, required this.onShowAddWaterDialog});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background SVG image
        SvgPicture.asset(
          'assets/svg/bottle.svg',
          color: const Color(0xFFE5E5E5),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
        // Smoothly animated overlaid color corresponding to the progress
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: const Duration(milliseconds: 500),
          builder: (context, animatedProgress, child) {
            return ClipRect(
              clipper: _ProgressClipper(animatedProgress),
              child: SvgPicture.asset(
                'assets/svg/bottle.svg',
                color: const Color(0xFF5B8ADB),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
        // Centered text and button
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  "${_getProgressText(progress, dailyGoal)}/${_getProgressText(1, dailyGoal)}",
                  style: const TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 15.0,
                        color: Color.fromARGB(179, 0, 0, 0),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  minFontSize: 12,
                  maxFontSize: 38,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: 57,
                width: 171,
                child: ElevatedButton(
                  onPressed: onShowAddWaterDialog,
                  child: const Text('Adicionar', style: TextStyle(fontSize: 25, color: Color(0xFF5B8ADB))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getProgressText(double progress, double max) {
    String formatValue(double value) {
      if (value % 1 == 0) {
        return '${value.toInt()}L';
      } else if ((value * 10) % 1 == 0) {
        return '${value.toStringAsFixed(1)}L';
      } else {
        return '${value.toStringAsFixed(2)}L';
      }
    }

    double currentAmount = progress * max;
    return formatValue(currentAmount);
  }
}

class _ProgressClipper extends CustomClipper<Rect> {
  final double progress;

  _ProgressClipper(this.progress);

  @override
  Rect getClip(Size size) {
    double height = size.height * (1.0 - progress);
    return Rect.fromLTWH(0, height, size.width, size.height - height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper != this;
  }
}

class AddWaterDialog extends StatefulWidget {
  final void Function(double) onIncreaseProgress;

  const AddWaterDialog({super.key, required this.onIncreaseProgress});

  @override
  _AddWaterDialogState createState() => _AddWaterDialogState();
}

class _AddWaterDialogState extends State<AddWaterDialog> {
  double customAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Água'),
      content: SizedBox(
        width: 300,
        height: 230,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onIncreaseProgress(0.1);
                  Navigator.of(context).pop();
                },
                child: const Text('100 ml'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onIncreaseProgress(0.2);
                  Navigator.of(context).pop();
                },
                child: const Text('200 ml'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onIncreaseProgress(0.5);
                  Navigator.of(context).pop();
                },
                child: const Text('500 ml'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Quantidade Personalizada'),
                        content: SizedBox(
                          width: 300, // Set the fixed width for the dialog
                          height: 120,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Selecione a quantidade (L)'),
                              StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return Slider(
                                    value: customAmount,
                                    min: 0,
                                    max: 5,
                                    divisions: 100,
                                    label: '${customAmount.toStringAsFixed(2)}L',
                                    onChanged: (double value) {
                                      setState(() {
                                        customAmount = value;
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              widget.onIncreaseProgress(customAmount);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Quantidade Personalizada'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
