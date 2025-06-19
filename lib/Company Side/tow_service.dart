import 'package:roadside_assistance/Company%20Side/client_issue_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Drawer.dart';
import 'CompanyNotification.dart';
import 'issue_details.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class TowServiceScreen extends StatefulWidget {
  const TowServiceScreen({super.key});

  @override
  State<TowServiceScreen> createState() => _TowServiceScreenState();
}

class _TowServiceScreenState extends State<TowServiceScreen> {
  bool isAvailable = false;
  String? companyAddress;
  String? loginTime;
  String companyName = "EeZee Tow"; // You can fetch this from Firestore if needed

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
          companyName = snapshot["name"] ?? "EeZee Tow";
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      drawer: CompanyDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.7),
              elevation: 0,
              title: Text(
                "Welcome Eezee Town",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: const Color(0xFF001E62),
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Color(0xFF001E62)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompanyNotificationsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
              iconTheme: const IconThemeData(color: Color(0xFF001E62)),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated Lottie background
          
          // Hero Banner
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.08),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFFe0e7ff),
                          radius: 38,
                          child: Image.asset(
                            'assets/HelpSupport.png',
                            width: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            
                              Text(
                                companyName,
                                style: GoogleFonts.poppins(
                                  color: Color(0xFF001E62),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Color(0xFF001E62), size: 20),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      companyAddress ?? "Fetching location...",
                                      style: GoogleFonts.poppins(
                                        color: Color(0xFF001E62),
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isAvailable ? Colors.green[50] : Colors.red[50],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: isAvailable ? Colors.green : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isAvailable ? "Online" : "Offline",
                                          style: GoogleFonts.poppins(
                                            color: isAvailable ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 140),
                // Animated Availability Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isAvailable ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.12),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: isAvailable ? Colors.green : Colors.redAccent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isAvailable ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: isAvailable
                                ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)]
                                : [BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isAvailable ? "Online" : "Offline",
                          style: GoogleFonts.poppins(
                            color: isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: isAvailable,
                          activeColor: Color(0xFF001E62),
                          onChanged: (val) => _toggleAvailability(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isAvailable ? "Available for requests" : "Not available",
                          style: GoogleFonts.poppins(
                            color: isAvailable ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.list_alt, color: Color(0xFF001E62)),
                      SizedBox(width: 8),
                      Text(
                        "Pending Requests",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF001E62),
                        ),
                      ),
                    ],
                  ),
                ),
                // Request List or Empty State
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: isAvailable
                        ? _buildRequestList()
                        : _buildEmptyState(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation for empty state
          SizedBox(
            width: 180,
            height: 180,
            child: Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_jtbfg2nb.json',
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No requests right now!",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF001E62)),
          ),
          const SizedBox(height: 8),
          Text(
            "Enjoy your break. We'll notify you when a new request arrives.",
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Request List with animated cards
  Widget _buildRequestList() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('companyId', isEqualTo: uid)
          .where("status", isEqualTo: "pending")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        var requests = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index];
            var data = request.data() as Map<String, dynamic>;
            return AnimatedSlide(
              offset: Offset(0, 0.1),
              duration: Duration(milliseconds: 400 + index * 80),
              curve: Curves.easeOut,
              child: BuildRequestCard(
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
              ),
            );
          },
        );
      },
    );
  }
}

// Redesigned Request Card
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glassmorphism effect
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vertical status bar
                    Container(
                      width: 8,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Color(0xFF001E62),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(0xFFc7d2fe),
                                  radius: 22,
                                  child: Icon(Icons.directions_car, color: Color(0xFF001E62), size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    carNo,
                                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert, color: Color(0xFF001E62)),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'call',
                                      child: Row(
                                        children: [
                                          Icon(Icons.phone, color: Color(0xFF001E62)),
                                          SizedBox(width: 8),
                                          Text('Call Client'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'map',
                                      child: Row(
                                        children: [
                                          Icon(Icons.map, color: Color(0xFF001E62)),
                                          SizedBox(width: 8),
                                          Text('View on Map'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    // Implement actions if needed
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Chip(
                                  label: Text(selected_vehicle, style: GoogleFonts.poppins(fontSize: 13)),
                                  backgroundColor: Color(0xFFe0e7ff),
                                ),
                                Chip(
                                  label: Text(car_color, style: GoogleFonts.poppins(fontSize: 13)),
                                  backgroundColor: Color(0xFFf5f6fa),
                                ),
                                Chip(
                                  label: Text(selected_service, style: GoogleFonts.poppins(fontSize: 13)),
                                  backgroundColor: Color(0xFFc7d2fe),
                                ),
                                Chip(
                                  label: Text(car_no, style: GoogleFonts.poppins(fontSize: 13)),
                                  backgroundColor: Color(0xFFe0e7ff),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _acceptRequest(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: StadiumBorder(),
                                    elevation: 2,
                                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.check, color: Colors.white, size: 20),
                                  label: Text("Accept", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _deleteRequest(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: StadiumBorder(),
                                    elevation: 2,
                                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                  label: Text("Decline", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    // Fetch full request data from Firestore
                                    var requestDoc = await FirebaseFirestore.instance
                                        .collection('requests')
                                        .doc(requestId)
                                        .get();
                                    if (requestDoc.exists) {
                                      var requestData =
                                          requestDoc.data() as Map<String, dynamic>;

                                      requestData["_id"] = requestId;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => IssueDetails(
                                            requestData: requestData,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Request not found")),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF001E62),
                                    shape: StadiumBorder(),
                                    elevation: 2,
                                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.visibility, color: Colors.white, size: 20),
                                  label: Text("View", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  void _acceptRequest(BuildContext context) async {
    var requestDoc = await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .get();
    if (requestDoc.exists) {
      var data = requestDoc.data() as Map<String, dynamic>;
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        "status": "accepted",
        'timestamp': FieldValue.serverTimestamp(),
        "_id": requestId
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request accepted and moved to service history")),
      );
    }
  }

  void _deleteRequest(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({
      "status": "rejected",
      'timestamp': FieldValue.serverTimestamp(),
      "_id": requestId
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request removed")),
    );
  }
}
