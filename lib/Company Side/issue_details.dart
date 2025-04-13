import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'client_issue_details.dart';

class IssueDetails extends StatefulWidget {
  var requestData;
   IssueDetails({super.key, this.requestData});

  @override
  State<IssueDetails> createState() => _IssueDetailsState();
}

class _IssueDetailsState extends State<IssueDetails> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                      _buildDetailRow("Vehicle Owner",widget.requestData['car_no']),
                      _buildDetailRow(
                          "Vehicle Type", widget.requestData['selected_service']),
                      _buildDetailRow(
                          "Vehicle Name", widget.requestData['selected_vehicle']),
                      _buildDetailRow("Vehicle Color", widget.requestData['car_color']),
                    ],
                  ),
                  _buildCard(
                    title: "Client Service Request",
                    children: [
                      _buildDetailRow("Client Issue Type", widget.requestData['details']),
                      _buildDetailRow("Client Location", widget.requestData['location'],
                          isLink: true),
                      _buildDetailRow("Client Contact", issueData['contact_no']),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                   color: Colors.white,
                elevation: 3,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                          ],
                        ),
                      ),
                    ),
                  ),
      
                  // _buildCard(
                  //   title: "Client Added Text",
                  //   children: [
                  //     const Text(
                  //       "description :",
                  //       style:
                  //           TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Text(
                  //         issueData['details'] ?? "No description provided.",
                  //         style: const TextStyle(
                  //             fontSize: 14, fontWeight: FontWeight.w500),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  _buildButtons(context,widget.requestData),
                ],
              ),
            );
          },
        ),
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
    return Container(
      child: Column(
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
      ),
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


  void _acceptRequest(BuildContext context,requestId) async {

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId) 
          .update({
        "status": "accepted",
        'timestamp': FieldValue.serverTimestamp(),
        "_id":requestId
      });
     
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Request accepted and moved to service history")),
      );
    
  }

  void _deleteRequest(BuildContext context,requestId) async {
   
      await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({
          "status":"rejected",
          'timestamp': FieldValue.serverTimestamp(),
         "_id":requestId
        });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request removed")),
    );
    Navigator.pop(context);
  }

  Widget _buildButtons(BuildContext context,requestData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildButtonDec(context, "Decline",requestData),
          _buildButtonAce(context, "Accept",requestData),
        ],
      ),
    );
  }

  Widget _buildButtonDec(BuildContext context, String text,requestData) {
    return ElevatedButton(
      onPressed: () {
   _deleteRequest(context,requestData["_id"]);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF001E62),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(140, 45),
      ),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildButtonAce(BuildContext context, String text,requestData) {
    return ElevatedButton(
      onPressed: () async {

          await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestData["_id"]) // Replace with your company ID
          .update({
        "status": "accepted",
        'timestamp': FieldValue.serverTimestamp(),
         "_id":requestData["_id"]
      });
     
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Request accepted and moved to service history")),
      );
      Navigator.pop(context);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const ClientIssueDetails()),
        // );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF001E62),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(140, 45),
      ),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
    );
  }
}
