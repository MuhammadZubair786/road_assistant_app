import 'package:firebase_app/User%20Side/HistoryInfo.dart';
import 'package:firebase_app/User%20Side/side_drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceHistory extends StatefulWidget {
  const ServiceHistory({super.key});

  @override
  _ServiceHistoryState createState() => _ServiceHistoryState();
}

class _ServiceHistoryState extends State<ServiceHistory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 tabs: Pending, Accepted, Completed, Rejected
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideDrawer(),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF001E62), Colors.white],
              ),
            ),
            child: Stack(alignment: AlignmentDirectional.center, children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),

                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  }
                ),
              ),
              const Positioned(
                top: 80,
                child: Text(
                  "History of Services",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ]),
          ),
          
          // Tabs
           TabBar(
                  controller: _tabController,
                  // labelColor: Colors.white,
                  isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 5,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Completed'),
              Tab(text: 'Rejected'),
            ],
          ),

          // Display content based on the selected tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildServiceList("pending"),
                _buildServiceList("accepted"),
                _buildServiceList("completed"),
                _buildServiceList("rejected"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to fetch services based on status
  Widget _buildServiceList(String status) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
           .where("status", isEqualTo: status)
          .where("user_id", isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return  Center(child: Text("No ${status.toString()} service history available"));
        }

        var services = snapshot.data!.docs;
        return ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            var service = services[index].data() as Map<String, dynamic>;

            return buildServiceCard(
              context,
              service,
              service['selected_service'] ?? "Unknown Service",
              service['location'] ?? "Unknown Location",
              service['timestamp'] != null
                  ? (service['timestamp'] as Timestamp).toDate().toString()
                  : "Unknown Date",
              _getServiceIcon(service['selected_service']),
            );
          },
        );
      },
    );
  }

  // Map services to their respective icons
  IconData _getServiceIcon(String? service) {
    switch (service) {
      case "Flat tire":
        return Icons.tire_repair;
      case "Towing Service":
        return Icons.local_shipping;
      case "Engine Heat":
        return Icons.warning;
      case "Battery Jump Start":
        return Icons.battery_charging_full;
      case "Engine Check":
        return Icons.settings;
      case "Key Lock":
        return Icons.vpn_key;
      default:
        return Icons.miscellaneous_services;
    }
  }
}

// Reusable Card Widget
Widget buildServiceCard(BuildContext context, Map<String, dynamic> service,
    String title, String address, String time, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
               crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_filled,
                            size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),

          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF001E62),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                       const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) =>
              //             HistoryInformation(requestData: service),
              //       ),
              //     );
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFF001E62),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              //   ),
              //   child: const Text(
              //     "Done",
              //     style: TextStyle(
              //         fontSize: 12,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.white),
              //   ),
              // ),
              SizedBox(width: 20,),
               ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HistoryInformation(requestData: service),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001E62),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
                child: const Text(
                  "Details",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
