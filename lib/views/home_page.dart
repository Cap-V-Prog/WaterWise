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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final double progress = data['progress'] ?? 0.0;
        final double dailyGoal = data['dailyGoal'] ?? 3.0;

        return Center(
          child: SizedBox(
            width: 210,
            height: 600,
            child: ProgressBar(
              progress: progress,
              dailyGoal: dailyGoal,
              onShowAddWaterDialog: _showAddWaterDialog,
            ),
          ),
        );
      },
    );
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

  Future<void> _increaseProgress(double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final double currentProgress = data['progress'] ?? 0.0;
        final double dailyGoal = data['dailyGoal'] ?? 3.0;
        final double newProgress = min(1.0, currentProgress + amount / dailyGoal);

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'progress': newProgress,
          'lastUpdated': Timestamp.fromDate(DateTime.now()),
        }, SetOptions(merge: true));
      }
    }
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
      title: const Text('Adicionar Água',style: TextStyle(color: Color(0xFF5B8ADB)),),
      content: SizedBox(
        width: 300,
        height: 230,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B8ADB),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  widget.onIncreaseProgress(0.22);
                  Navigator.of(context).pop();
                },
                child: const Text('220 ml'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B8ADB),
                  foregroundColor: Colors.white,
                ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B8ADB),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Quantidade Personalizada',style: TextStyle(color: Color(0xFF5B8ADB)),),
                        content: SizedBox(
                          width: 300, // Set the fixed width for the dialog
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Insira a quantidade (L)',style: TextStyle(fontSize: 20,color: Color(0xFF5B8ADB)),),
                              Container(height: 10,),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 15, color: Colors.white),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  fillColor: Color(0xFF5B8ADB),
                                  filled: true,
                                  hintText: "Quantidade em Litros",
                                  hintStyle: const TextStyle(color: Colors.white),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    customAmount = double.tryParse(value) ?? 0.0;
                                  });
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
                            child: const Text('Adicionar',),
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
          child: const Text('Cancel',style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
