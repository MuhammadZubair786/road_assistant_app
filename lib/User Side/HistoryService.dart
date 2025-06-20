import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:roadside_assistance/User%20Side/HistoryInfo.dart';
import 'package:roadside_assistance/User%20Side/side_drawer.dart';

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return "";
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class ServiceHistory extends StatefulWidget {
  const ServiceHistory({super.key});

  @override
  _ServiceHistoryState createState() => _ServiceHistoryState();
}

class _ServiceHistoryState extends State<ServiceHistory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 4, vsync: this); // 4 tabs: Pending, Accepted, Completed, Rejected
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
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF001E62),
                  Color(0xFF001E62).withOpacity(0.95),
                ],
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        const Spacer(),
                        const Text(
                          'Service History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // To balance the IconButton
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: const Color(0xFF001E62),
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: 'Pending'),
                        Tab(text: 'Accepted'),
                        Tab(text: 'Completed'),
                        Tab(text: 'Rejected'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          return Center(
            child: Text(
              "No ${status.capitalize()} services",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          );
        }

        var services = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemCount: services.length,
          itemBuilder: (context, index) {
            var serviceData = services[index].data() as Map<String, dynamic>;
            serviceData['documentId'] = services[index].id;
            return buildServiceCard(context, serviceData, status);
          },
        );
      },
    );
  }

  IconData _getServiceIcon(String? service) {
    switch (service) {
      case "Flat tire":
        return Icons.tire_repair;
      case "Towing Service":
        return Icons.local_shipping;
      case "Engine Heat":
        return Icons.warning_amber_rounded;
      case "Battery Jump Start":
        return Icons.battery_charging_full;
      case "Engine Check":
        return Icons.miscellaneous_services_rounded;
      case "Key Lock":
        return Icons.vpn_key_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

Widget buildServiceCard(
    BuildContext context, Map<String, dynamic> service, String status) {
  final String title = service['selected_service'] ?? "Unknown Service";
  final String location = service['location'] ?? "Unknown Location";
  final Timestamp timestamp = service['timestamp'] as Timestamp;
  final String formattedDate =
      DateFormat('MMM d, yyyy').format(timestamp.toDate());
  final String formattedTime =
      DateFormat('h:mm a').format(timestamp.toDate());
  final String cost = service['cost'] ?? 'N/A';
  final IconData icon =
      (context.findAncestorStateOfType<_ServiceHistoryState>()!)
          ._getServiceIcon(title);
  final Color primaryColor = const Color(0xFF001E62);

  Color statusColor;
  switch (status) {
    case 'completed':
      statusColor = Colors.green;
      break;
    case 'rejected':
      statusColor = Colors.red;
      break;
    case 'accepted':
      statusColor = Colors.blue;
      break;
    default:
      statusColor = Colors.orange;
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryInformation(
              requestData: service,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored accent bar
            Container(
              width: 6,
              height: 110,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Icon
            Padding(
              padding: const EdgeInsets.only(top: 18.0, left: 2, right: 8),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: primaryColor.withOpacity(0.10),
                child: Icon(icon, color: primaryColor, size: 28),
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            status.capitalize(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 5),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 14),
                        Icon(Icons.access_time, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 5),
                        Text(
                          formattedTime,
                          style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 5),
                        Text(
                          cost == 'N/A' ? 'N/A' : '\$24$cost',
                          style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 14),
                        Icon(Icons.location_on_outlined, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    ),
  );
}
