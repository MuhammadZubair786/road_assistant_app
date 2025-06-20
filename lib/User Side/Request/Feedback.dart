import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_screen.dart';

// ignore: must_be_immutable
class FeedbackScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var requestData;
  FeedbackScreen({super.key, required this.requestData});
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 0;
  String companyName = "Loading...";
  String companyAddress = "Fetching location...";
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCompanyDetails();
  }

  Future<void> _fetchCompanyDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Company')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          companyName = doc['name'] ?? "No Name";
          companyAddress = doc['address'] ?? "No Address";
        });
      }
    } catch (e) {
      print("Error fetching company details: $e");
    }
  }

  Future<void> submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    final requestId = widget.requestData["_id"];

    if (user == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Feedback')
          .where('userId', isEqualTo: user.uid)
          .where('requestId', isEqualTo: requestId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('Feedback').add({
          'userId': user.uid,
          'requestId': requestId,
          'companyName': widget.requestData["companyName"],
          'companyAddress': widget.requestData["companyAddress"],
          'rating': _rating,
          'comment': _commentController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Thank you for your feedback!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF001E62),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You've already submitted feedback for this request.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF001E62);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Decorative Illustration
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor, primaryColor.withOpacity(0.95)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Illustration (trophy or stars)
                    Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 54),
                    const SizedBox(height: 8),
                    const Text(
                      "Rate Your Experience",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Your feedback helps us improve!",
                      style: TextStyle(
                        fontSize: 15.5,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Company Info Card
            Card(
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryColor.withOpacity(0.10),
                      child: const Icon(Icons.business_rounded, color: Color(0xFF001E62), size: 32),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyAddress,
                            style: TextStyle(
                              fontSize: 14.5,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Rating Section with colored accent
            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.06),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 7,
                      decoration: BoxDecoration(
                        color: Colors.amber[600],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                    child: Column(
                      children: [
                        const Text(
                          "How would you rate the service?",
                          style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 18),
                        AnimatedScale(
                          scale: _rating > 0 ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star_rounded,
                              color: Colors.amber[700],
                              size: 38,
                            ),
                            unratedColor: Colors.grey[300],
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Divider and Comment Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "Comments",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.06),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Share your thoughts...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text(
                    "Submit Feedback",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
