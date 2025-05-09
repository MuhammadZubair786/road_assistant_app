import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadside_assistance/Company%20Side/CompanyNotification.dart';
import 'package:roadside_assistance/Company%20Side/Drawer.dart';
import 'package:roadside_assistance/Company%20Side/client_issue_details.dart';
import 'package:roadside_assistance/Company%20Side/issue_details.dart';
import 'package:roadside_assistance/Company%20Side/issuedetailsAccept.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'viewClinetDetails.dart';

class Track extends StatefulWidget {
  @override
  _TrackState createState() => _TrackState();
}

class _TrackState extends State<Track> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CompanyDrawer(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          TabBar(
            isScrollable: true,
            controller: _tabController,
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(text: "Service Requests"),
               Tab(text: "Active Request"),
              Tab(text: "Service History"),
            ],
          ),
          Expanded(
            child: TabBarView(
          
              controller: _tabController,
              children: [
                _buildServiceRequestList(),
              _buildServiceCurrent(),
                _buildServiceHistory(),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF001E62), Colors.white],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompanyNotificationsScreen(),
                  ),
                );
              },
              icon: Icon(Icons.notifications, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildServiceRequestList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests') // Updated to match RequestConfirmation
            .where("companyId",isEqualTo:FirebaseAuth.instance.currentUser!.uid )
            .where("status",isEqualTo: "pending")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending service requests available."));
          }
          var serviceRequests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: serviceRequests.length,
            itemBuilder: (context, index) {
              var serviceData =
                  serviceRequests[index].data() as Map<String, dynamic>;
              var car_no = serviceData['car_no'] ?? 'Unknown';
              var car_color = serviceData['car_color'] ?? 'Unknown';
              var selected_service =
                  serviceData['selected_service'] ?? 'Unknown';
              var selected_vehicle =
                  serviceData['selected_vehicle'] ?? 'Unknown';
              var location = serviceData['location'] ?? 'Unknown';
              var timestamp = serviceData['timestamp'] as Timestamp?;
              String formattedDate = timestamp != null
                  ? "${timestamp.toDate().toLocal()}"
                  : "Unknown time";
              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 6,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$car_no",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                          "$selected_vehicle | $car_color | $selected_service | $car_no",
                          style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {

                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF001E62)),
                            child: const Text("Done",
                                style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        IssueDetailsAccept(requestData: serviceData)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF001E62)),
                            child: const Text("Locate Client",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceHistory() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:  StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests') // Updated to match RequestConfirmation
            .where("companyId",isEqualTo:FirebaseAuth.instance.currentUser!.uid )
            .where("status",isEqualTo: "completed")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No completed service history available."));
          }

          var services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              var service = services[index].data() as Map<String, dynamic>;
              var carNo = service['car_no'] ?? 'Unknown';
              var selectedVehicle = service['selected_vehicle'] ?? 'Unknown';
              var vehicleColor = service['Vehicle_color'] ?? 'Unknown';
              var selectedService = service['selected_service'] ?? 'Unknown';
              var vehicleNo = service['Vehicle_no'] ?? 'Unknown';
              var timestamp = service['timestamp'] as Timestamp?;
              String formattedDate = timestamp != null
                  ? "${timestamp.toDate().toLocal()}"
                  : "Unknown time";

              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>IssueDetailsHistory(requestData: service,)));

                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(carNo,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            "$selectedVehicle | $vehicleColor | $selectedService | $vehicleNo"),
                        SizedBox(height: 10),
                        Text(formattedDate,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildServiceCurrent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:  StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests') // Updated to match RequestConfirmation
            .where("companyId",isEqualTo:FirebaseAuth.instance.currentUser!.uid )
            .where("status",isEqualTo: "accepted")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No current service history available."));
          }

          var services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              var service = services[index].data() as Map<String, dynamic>;
              var carNo = service['car_no'] ?? 'Unknown';
              var selectedVehicle = service['selected_vehicle'] ?? 'Unknown';
              var vehicleColor = service['Vehicle_color'] ?? 'Unknown';
              var selectedService = service['selected_service'] ?? 'Unknown';
              var vehicleNo = service['Vehicle_no'] ?? 'Unknown';
              var timestamp = service['timestamp'] as Timestamp?;
              String formattedDate = timestamp != null
                  ? "${timestamp.toDate().toLocal()}"
                  : "Unknown time";

              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>IssueDetailsHistory(requestData: service,)));

                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(carNo,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            "$selectedVehicle | $vehicleColor | $selectedService | $vehicleNo"),
                        SizedBox(height: 10),
                        Text(formattedDate,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
