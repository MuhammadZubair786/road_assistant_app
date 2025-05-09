import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'issue_details.dart';

class ClientIssueDetails extends StatelessWidget {
  const ClientIssueDetails({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No client issues found."));
          }
          var issueData = snapshot.data!.docs.first;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildCard(
                  title: "Vehicle Details",
                  children: [
                    _buildDetailRow("Vehicle Owner", issueData['car_no']),
                    _buildDetailRow(
                        "Vehicle Type", issueData['selected_service']),
                    _buildDetailRow(
                        "Vehicle Name", issueData['selected_vehicle']),
                    _buildDetailRow("Vehicle Color", issueData['car_color']),
                  ],
                ),
                _buildCard(
                  title: "Client Service Request",
                  children: [
                    _buildDetailRow("Client Issue Type", issueData['details']),
                    _buildDetailRow("Client Location", issueData['location'],
                        isLink: true),
                    _buildDetailRow("Client Contact", issueData['contact_no']),
                  ],
                ),
                _buildCard(
                  title: "Client Added Text",
                  children: [
                    const Text(
                      "description :",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        issueData['details'] ?? "No description provided.",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    _buildButtons(context),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF001E62), Colors.white],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
            const Text(
              "Client Issue Details",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Card(
            color: Colors.white,
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const SizedBox(height: 8), ...children],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          const Text(":",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isLink ? const Color(0xFF001E62) : Colors.grey,
              decoration:
                  isLink ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  final String phoneNumber = "+92 3443680807"; // Replace with real phone number
  final String whatsappMessage = "Hello! I’d like to connect with you.";

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Row(
        children: [
          Expanded(child: _buildButton(context, "Message")),
          SizedBox(width: 16),
          Expanded(child: _buildButton(context, "Call")),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text) {
    return ElevatedButton(
      onPressed: () => _handleButtonPress(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF001E62),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(0, 45), // Set width to 0 for flexible layout
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
      ),
    );
  }

  void _handleButtonPress(String type) async {
    if (type == "Message") {
      final whatsappUrl = Uri.parse(
          "https://wa.me/${phoneNumber.replaceAll('+', '')}?text=${Uri.encodeComponent(whatsappMessage)}");
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch WhatsApp");
      }
    } else if (type == "Call") {
      final callUrl = Uri.parse("tel:$phoneNumber");
      if (await canLaunchUrl(callUrl)) {
        await launchUrl(callUrl);
      } else {
        debugPrint("Could not open dialer");
      }
    }
  }
}
