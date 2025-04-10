import 'package:firebase_app/lib/Company%20Side/client_issue_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Drawer.dart';
import 'CompanyNotification.dart';
import 'issue_details.dart';

class TowServiceScreen extends StatefulWidget {
  const TowServiceScreen({super.key});

  @override
  State<TowServiceScreen> createState() => _TowServiceScreenState();
}

class _TowServiceScreenState extends State<TowServiceScreen> {
  bool isAvailable = false;
  String? companyAddress;
  String? loginTime;

  @override
  void initState() {
    super.initState();
    _getAvailability();
  }

  void _getAvailability() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isNotEmpty) {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('Company').doc(uid).get();

      if (snapshot.exists) {
        setState(() {
          isAvailable = snapshot['isAvailable'] ?? false;
          companyAddress = snapshot["address"] ?? "Location not available";

          isAvailable = snapshot["isAvailable"] ?? true;
        });
      }
    }
  }

  void _toggleAvailability() async {
    setState(() {
      isAvailable = !isAvailable;
    });

    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('Company').doc(uid).update({
        'isAvailable': isAvailable,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CompanyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: _buildHeader(),
          ),
          _buildLocationHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  isAvailable ?   _buildRequestList():const SizedBox.shrink(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on,
                  color: isAvailable ? Color(0xFF001E62) : Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAvailable
                          ? (companyAddress ?? "Fetching location...")
                          : "Disable",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isAvailable ? Colors.black : Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14,
                            color:
                                isAvailable ? Colors.grey : Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          isAvailable
                              ? (loginTime ?? "09:00 AM - 5:00 PM")
                              : "Disable",
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  isAvailable ? Colors.grey : Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: _toggleAvailability,
              child: Container(
                width: 160,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isAvailable ? Color(0xFF001E62) : Colors.redAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  isAvailable ? "Enable" : "Disable",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 100,
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
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompanyNotificationsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(clipBehavior: Clip.none, children: [
      Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Color(0xFF001E62), borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text("EeZee Tow",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }

  Widget _buildRequestList() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return StreamBuilder<QuerySnapshot>(
       stream: FirebaseFirestore.instance
          .collection('requests')
           .where('company_id', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No any new rides for you"));
        }

        var requests = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index];
            var data = request.data() as Map<String, dynamic>;
            // Debugging: Print document data
            print("Document Data: $data");
            return BuildRequestCard(
              requestId: request.id,
              carNo: data.containsKey('car_no') ? data['car_no'] : 'Unknown',
              selected_vehicle: data.containsKey('selected_vehicle')
                  ? data['selected_vehicle']
                  : 'No Vehicle',
              car_color: data.containsKey('car_color')
                  ? data['car_color']
                  : 'No Color',
              selected_service: data.containsKey('selected_service')
                  ? data['selected_service']
                  : 'No service',
              car_no: data.containsKey('car_no')
                  ? data['car_no']
                  : 'No Vehicle Number',
            );
          },
        );
      },
    );
  }
}

class BuildRequestCard extends StatelessWidget {
  final String requestId;
  final String carNo;
  final String selected_vehicle;
  final String car_color;
  final String selected_service;
  final String car_no;

  const BuildRequestCard({
    required this.requestId,
    required this.carNo,
    required this.selected_vehicle,
    required this.car_color,
    required this.selected_service,
    required this.car_no,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$carNo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("$selected_vehicle | $car_color | $selected_service | $car_no",
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _acceptRequest(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF001E62)),
                  child: Text("Accept", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => _deleteRequest(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF001E62)),
                  child: Text("Decline", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Fetch full request data from Firestore
                    var requestDoc = await FirebaseFirestore.instance
                        .collection('requests')
                        .doc(requestId)
                        .get();
                    if (requestDoc.exists) {
                      var requestData =
                          requestDoc.data() as Map<String, dynamic>;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IssueDetails(
                            requestData: {},
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Request not found")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF001E62)),
                  child: Text("View", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptRequest(BuildContext context) async {
    // Fetch the request details from Firestore
    var requestDoc = await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .get();
    if (requestDoc.exists) {
      var data = requestDoc.data() as Map<String, dynamic>;

      // Add to the accepted_services collection
      await FirebaseFirestore.instance
          .collection('Company')
          .doc("YOUR_COMPANY_ID") // Replace with your company ID
          .collection('accepted_services')
          .add({
        'car_no': data['car_no'],
        'selected_vehicle': data['selected_vehicle'],
        'car_color': data['car_color'],
        'selected_service': data['selected_service'],
        'car_no': data['car_no'],
        'timestamp': FieldValue.serverTimestamp(),
      });
      // Update the request status to 'accepted'
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({'status': 'accepted'});

      // Delete the request from the current list
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Request accepted and moved to service history")),
      );
    }
  }

  void _deleteRequest(BuildContext context) async {
    // Delete the request without accepting it
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request removed")),
    );
  }
}
