import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_screen.dart';

class FeedbackScreen extends StatefulWidget {
  var requestData;
   FeedbackScreen({super.key,required this.requestData});
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
    widget.requestData;
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

  // Check if feedback already exists for this requestId by this user
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Feedback')
      .where('userId', isEqualTo: user.uid)
      .where('requestId', isEqualTo: requestId)
      .get();

  if (querySnapshot.docs.isEmpty) {
    // No feedback yet – allow submitting
    await FirebaseFirestore.instance.collection('Feedback').add({
      'userId': user.uid,
      'requestId': requestId,
      'companyName': widget.requestData["companyName"],
      'companyAddress': widget.requestData["companyAddress"], // Fixed copy/paste issue
      'rating': _rating,
      'comment': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Optional: Show success message or redirect
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted successfully",
      
      ),
       backgroundColor: Colors.green
      ),
    );
      // ignore: use_build_context_synchronously
       Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );

  } else {
    // Feedback already exists – block submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You've already submitted feedback for this request."),
       backgroundColor: Colors.red
      
      ),
      
      
    );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF001E62), Colors.white],
                ),
              ),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    child: Text(
                      "Feedback",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            const CircleAvatar(
              backgroundColor: Color(0xFF001E62),
              radius: 40,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(Icons.business, color: Colors.black, size: 25),
              ),
            ),
            const SizedBox(height: 10),
            Text(
               widget.requestData["companyName"], // Display fetched name
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.requestData["companyAddress"], // Display fetched address
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),
            const Text(
              "How is your experience?",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your feedback will help improve \nservice experience",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 40),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Color(0xFF001E62),
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 180,
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Additional Comments",
                    hintStyle: TextStyle(fontSize: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF001E62),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Submit Review",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
