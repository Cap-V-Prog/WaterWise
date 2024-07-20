import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _progress = 0; // Initially 0% progress

  void _increaseProgress() {
    setState(() {
      _progress = min(1.0, _progress + 0.1); // Increase progress by 10%
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 210, // Desired width of the image
        height: 600, // Adjusted height to accommodate the button
        child: ProgressBar(
          progress: _progress,
          onIncreaseProgress: _increaseProgress,
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double progress; // Progress value between 0 and 1
  final VoidCallback onIncreaseProgress;

  ProgressBar({required this.progress, required this.onIncreaseProgress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background SVG image
        SvgPicture.asset(
          'assets/svg/bottle.svg',
          color: Color(0xFFE5E5E5), // Color of the background image
          width: double.infinity, // Use the available width
          height: double.infinity, // Use the available height
          fit: BoxFit.contain,
        ),
        // Smoothly animated overlaid color corresponding to the progress
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: Duration(milliseconds: 500),
          builder: (context, animatedProgress, child) {
            return ClipRect(
              clipper: _ProgressClipper(animatedProgress),
              child: SvgPicture.asset(
                'assets/svg/bottle.svg',
                color: Color(0xFF5B8ADB), // Color of the overlaid image
                width: double.infinity, // Use the available width
                height: double.infinity, // Use the available height
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
                padding: EdgeInsets.all(8.0),
                child: AutoSizeText(
                  _getProgressText(progress, 3),
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 15.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  minFontSize: 12,
                  maxFontSize: 45,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onIncreaseProgress,
                child: Text('Aumentar Progressão'),
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
        return value.toInt().toString() + 'L';
      } else if ((value * 10) % 1 == 0) {
        return value.toStringAsFixed(1) + 'L';
      } else {
        return value.toStringAsFixed(2) + 'L';
      }
    }

    double currentValue = progress * max;
    return '${formatValue(currentValue)} / ${formatValue(max)}';
  }
}

class _ProgressClipper extends CustomClipper<Rect> {
  final double progress;

  _ProgressClipper(this.progress);

  @override
  Rect getClip(Size size) {
    // Change the clipping area for vertical progress
    return Rect.fromLTRB(0, size.height * (1 - progress), size.width, size.height);
  }

  @override
  bool shouldReclip(_ProgressClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
