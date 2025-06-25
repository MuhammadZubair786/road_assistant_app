import 'dart:async';
import 'package:flutter/material.dart';
import 'CompanyProfile.dart';

class CompanyVerificationCode extends StatefulWidget {
  final String correctOTP;
  final VoidCallback onResendOTP;
  CompanyVerificationCode(
      {super.key, required this.correctOTP, required this.onResendOTP});

  @override
  State<CompanyVerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<CompanyVerificationCode> {
  late Timer _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  final TextEditingController _otpController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        }
        if (_secondsRemaining == 0) {
          _canResend = true;
          _timer.cancel();
        }
      });
    });
  }

  void _resendOTP() {
    if (_canResend) {
      widget.onResendOTP(); // Call the passed function
      setState(() {
        _secondsRemaining = 60; // Reset to 60 seconds
        _canResend = false; // Disable the button
      });
      _startTimer(); // Restart the countdown timer

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("A new OTP has been sent!"),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOTP() async {
    String enteredOTP = _otpController.text.trim();
    if (enteredOTP == widget.correctOTP) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("OTP verified successfully! Redirecting..."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CompanyProfile()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Incorrect OTP. Please try again."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Gradient Header with Logo and Title
          Container(
            width: double.infinity,
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF001E62), Color(0xFF3A7BD5)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // App Logo
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/HelpSupport.png',
                        fit: BoxFit.contain,
                        height: 36,
                        width: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Verification',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black26,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Card for OTP input and actions
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Enter the 6-digit code sent to your number',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _otpController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Color(0xFFF5F6FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Enter OTP',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Time Remaining: " +
                            (_secondsRemaining ~/ 60).toString().padLeft(2, '0') +
                            ":" +
                            (_secondsRemaining % 60).toString().padLeft(2, '0'),
                          style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Montserrat'),
                        ),
                        const SizedBox(height: 20),
                        if (_canResend)
                          Center(
                            child: TextButton(
                              onPressed: _resendOTP,
                              child: const Text(
                                "Resend OTP",
                                style: TextStyle(color: Color(0xFF001E62), fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF001E62),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 4,
                            ),
                            onPressed: _verifyOTP,
                            child: const Text(
                              'Verify',
                              style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
