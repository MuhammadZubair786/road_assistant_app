import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:animate_do/animate_do.dart';

class VerificationCodeForget extends StatefulWidget {
  const VerificationCodeForget({super.key});

  @override
  State<VerificationCodeForget> createState() => _VerificationCodeForgetState();
}

class _VerificationCodeForgetState extends State<VerificationCodeForget> {
  final TextEditingController _otpController = TextEditingController();
  late Timer _timer;
  int _secondsRemaining = 120; // 2 minutes
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _secondsRemaining = 120;
    });
    _startTimer();
    // Add logic to resend code here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("A new verification code has been sent."),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _verifyOTP() {
    setState(() => _isLoading = true);
    // Simulate a network call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      if (_otpController.text == "123456") { // Dummy OTP
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Verification Successful!"),
              backgroundColor: Colors.green),
        );
        // Navigate to the next screen (e.g., reset password)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Invalid OTP. Please try again."),
              backgroundColor: Colors.red),
        );
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF001E62);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: TextStyle(
          fontSize: 22,
          color: primaryColor,
          fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: primaryColor, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: primaryColor.withOpacity(0.1),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primaryColor, primaryColor.withOpacity(0.95)],
              ),
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Positioned(
                    left: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Verification',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset(
                      'assets/verificationImage.png',
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              'Enter Verification Code',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                             Text(
                              "We've sent a 6-digit code to your email address.", // Add user's email if available
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15.5, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 28),
                            Pinput(
                              controller: _otpController,
                              length: 6,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: submittedPinTheme,
                              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                              showCursor: true,
                              onCompleted: (pin) => _verifyOTP(),
                            ),
                            const SizedBox(height: 24),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive the code? ",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextButton(
                                  onPressed: _secondsRemaining == 0 ? _resetTimer : null,
                                  child: Text(
                                    _secondsRemaining == 0
                                        ? "Resend"
                                        : "Resend in ${_formatTime(_secondsRemaining)}",
                                    style: TextStyle(
                                      color: _secondsRemaining == 0 ? primaryColor : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading || _otpController.text.length < 6 ? null : _verifyOTP,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 3,
                                ),
                                icon: _isLoading
                                    ? Container(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : const Icon(Icons.check_circle_outline, color: Colors.white),
                                label: Text(
                                  _isLoading ? 'Verifying...' : 'Verify',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
