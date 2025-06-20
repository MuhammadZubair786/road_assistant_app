import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'Request/Feedback.dart';

class HistoryInformation extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const HistoryInformation({Key? key, required this.requestData})
      : super(key: key);

  @override
  _HistoryInformationState createState() => _HistoryInformationState();
}

class _HistoryInformationState extends State<HistoryInformation> {
  String _companyName = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchCompanyName();
  }

  Future<void> fetchCompanyName() async {
    try {
      if (widget.requestData['companyId'] != null) {
        DocumentSnapshot companyDoc = await FirebaseFirestore.instance
            .collection('Company')
            .doc(widget.requestData['companyId'])
            .get();

        if (companyDoc.exists) {
          setState(() {
            _companyName = companyDoc['name'] ?? "No Name";
          });
        } else {
          setState(() {
            _companyName = "Unknown Company";
          });
        }
      } else {
        _companyName = "Not Assigned";
      }
    } catch (e) {
      print("Error fetching company name: $e");
      setState(() {
        _companyName = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF001E62);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.9),
                ],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 26),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Text(
                        'Service Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: 'Service & Vehicle',
                    icon: Icons.miscellaneous_services_rounded,
                    children: [
                      _buildInfoRow(
                          "Service Type",
                          widget.requestData['selected_service'] ?? "N/A",
                          Icons.settings_outlined),
                      _buildInfoRow(
                          "Vehicle",
                          widget.requestData['selected_vehicle'] ?? "N/A",
                          Icons.directions_car_filled_outlined),
                      _buildInfoRow("Vehicle No.",
                          widget.requestData['car_no'] ?? "N/A", Icons.pin_outlined),
                      _buildInfoRow("Vehicle Color",
                          widget.requestData['car_color'] ?? "N/A", Icons.color_lens_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Location & Issue',
                    icon: Icons.location_on_rounded,
                    children: [
                       _buildInfoRow("Location",
                          widget.requestData['location'] ?? "N/A", Icons.location_pin),
                       _buildInfoRow("Details",
                          widget.requestData['details'] ?? "N/A", Icons.description_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Other Details',
                    icon: Icons.person_rounded,
                    children: [
                       _buildInfoRow("Company", _companyName, Icons.business_center_rounded),
                       _buildInfoRow(
                          "Date & Time",
                          widget.requestData['timestamp'] != null
                              ? DateFormat('MMM d, yyyy  h:mm a')
                                  .format(widget.requestData['timestamp'].toDate())
                              : "N/A",
                          Icons.calendar_today_rounded),
                       _buildInfoRow("Contact No.",
                          widget.requestData['contact_no'] ?? "N/A", Icons.phone_outlined),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (widget.requestData["status"] == "accepted")
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showRequestDialog(
                            context,
                            widget.requestData,
                            () {
                              updateRequest(widget.requestData["documentId"],
                                  widget.requestData);
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.update, color: Colors.white),
                        label: const Text(
                          "Update Status",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF001E62), size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001E62)),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[500], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  updateRequest(requestId, requestdata) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({
      "status": "completed",
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Thanks For Using This Company Service!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FeedbackScreen(requestData: requestdata)));
  }

  showRequestDialog(
      BuildContext context, Map<String, dynamic> service, VoidCallback onAccept) {
    final Color primaryColor = const Color(0xFF001E62);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(Icons.check_circle_outline, color: primaryColor, size: 38),
                ),
                const SizedBox(height: 18),
                Text(
                  "Confirm Completion",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to mark this service as completed?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onAccept();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
