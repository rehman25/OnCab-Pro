import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/BottomScreen.dart';

class TimerModal extends StatefulWidget {
  final int duration; // Duration in seconds
  final VoidCallback onVerified;

  TimerModal({required this.duration, required this.onVerified});

  @override
  _TimerModalState createState() => _TimerModalState();
}

class _TimerModalState extends State<TimerModal>
    with SingleTickerProviderStateMixin {
  late int remainingTime;
  Timer? countdownTimer;
  Timer? verificationTimer;

  late AnimationController _controller;
  late Animation<double> _animation;

  static const String END_TIME_KEY = 'endTime';

  @override
  void initState() {
    super.initState();
    _loadEndTime();
  }

  /// Load end time from SharedPreferences, or initialize a new timer
  Future<void> _loadEndTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedEndTime = prefs.getInt(END_TIME_KEY);

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (storedEndTime != null && storedEndTime > currentTime) {
      // If there is a stored end time and it hasn't passed, calculate remaining time
      remainingTime = storedEndTime - currentTime;
    } else {
      // If no end time is stored, set the timer for the first time
      remainingTime = widget.duration;
      _storeEndTime();
    }

    _startTimer();
  }

  /// Store the end time in SharedPreferences
  void _storeEndTime() async {
    int endTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + remainingTime;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(END_TIME_KEY, endTime);
  }

  /// Start the countdown and animation
  void _startTimer() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: remainingTime),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime--;
      });

      if (remainingTime <= 0) {
        timer.cancel();
        _controller.stop();
        _clearEndTime();
        Navigator.pop(
          context,
        );
      }
    });

    // Check for document verification periodically
    verificationTimer =
        Timer.periodic(Duration(minutes: 1), (verificationTimer) async {
      bool isVerified = await checkDocumentVerificationStatus();
      if (isVerified) {
        verificationTimer.cancel();
        widget.onVerified();
        Navigator.pop(context, BottomScreen());
      }
    });
  }

  /// Clear the end time from SharedPreferences when the timer completes
  void _clearEndTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(END_TIME_KEY);
  }

  @override
  void dispose() {
    _controller.dispose();
    countdownTimer?.cancel();
    verificationTimer?.cancel();
    super.dispose();
  }

  /// Simulate checking the document verification status from an API
  Future<bool> checkDocumentVerificationStatus() async {
    await Future.delayed(Duration(seconds: 2));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    int hours = remainingTime ~/ 3600;
    int minutes = (remainingTime % 3600) ~/ 60;
    int seconds = remainingTime % 60;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Document Verification in Progress',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00155f)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00155f)),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Remaining Time',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            LinearProgressIndicator(
              value: _animation.value,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00155f)),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00155f), Color(0xFF00155f)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00155f).withOpacity(0.6),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Verifying Document...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
