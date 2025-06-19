import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  final String status;

  const ServiceDetailsPage({
    Key? key,
    required this.serviceData,
    required this.status,
  }) : super(key: key);

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  bool _isLoading = false;

  Future<void> _acceptRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the document ID from the service data
      String? documentId = widget.serviceData['documentId'];
      
      if (documentId == null) {
        // If documentId is not in the data, we need to find the document
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('requests')
            .where('car_no', isEqualTo: widget.serviceData['car_no'])
            .where('timestamp', isEqualTo: widget.serviceData['timestamp'])
            .where('companyId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          documentId = querySnapshot.docs.first.id;
        } else {
          throw Exception('Request document not found');
        }
      }

      // Update the status to 'accepted'
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(documentId)
          .update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'acceptedBy': FirebaseAuth.instance.currentUser!.uid,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request accepted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);

    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting request: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall() async {
    String phoneNumber = widget.serviceData['contact_no'] ?? '';
    if (phoneNumber.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No phone number available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _sendSMS() async {
    String phoneNumber = widget.serviceData['contact_no'] ?? '';
    if (phoneNumber.isNotEmpty) {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {
          'body': 'Hello! I am responding to your service request.',
        },
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch SMS app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No phone number available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _openWhatsApp() async {
    String phoneNumber = widget.serviceData['contact_no'] ?? '';
    if (phoneNumber.isNotEmpty) {
      // Remove any non-digit characters and add country code if needed
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (!phoneNumber.startsWith('91')) {
        phoneNumber = '91$phoneNumber'; // Add India country code
      }
      
      final Uri whatsappUri = Uri.parse(
        'https://wa.me/$phoneNumber?text=Hello! I am responding to your service request.'
      );
      
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch WhatsApp'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No phone number available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    SizedBox(height: 20),
                    _buildVehicleDetailsCard(),
                    SizedBox(height: 20),
                    _buildServiceDetailsCard(),
                    SizedBox(height: 20),
                    _buildClientDetailsCard(),
                    SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF001E62),
            Color(0xFF001E62).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.serviceData['car_no'] ?? 'Unknown Vehicle',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (widget.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_outlined;
        statusText = 'Pending';
        break;
      case 'active':
        statusColor = Colors.blue;
        statusIcon = Icons.directions_car_outlined;
        statusText = 'Active';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Completed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailsCard() {
    return _buildInfoCard(
      title: 'Vehicle Details',
      icon: Icons.directions_car,
      children: [
        _buildInfoRow('Vehicle Number', widget.serviceData['car_no'] ?? 'N/A'),
        _buildInfoRow('Vehicle Type', widget.serviceData['selected_vehicle'] ?? 'N/A'),
        _buildInfoRow('Vehicle Color', widget.serviceData['car_color'] ?? widget.serviceData['Vehicle_color'] ?? 'N/A'),
        _buildInfoRow('Service Type', widget.serviceData['selected_service'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildServiceDetailsCard() {
    var timestamp = widget.serviceData['timestamp'] as Timestamp?;
    String formattedDate = timestamp != null ? "${timestamp.toDate().toLocal().toString().split('.')[0]}" : "Unknown time";

    return _buildInfoCard(
      title: 'Service Details',
      icon: Icons.build_circle_outlined,
      children: [
        _buildInfoRow('Request Time', formattedDate),
        _buildInfoRow('Service Status', widget.status.capitalize()),
        _buildInfoRow('Description', widget.serviceData['details'] ?? 'No description provided'),
      ],
    );
  }

  Widget _buildClientDetailsCard() {
    return _buildInfoCard(
      title: 'Client Details',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow('Contact Number', widget.serviceData['contact_no'] ?? 'N/A'),
        _buildInfoRow('Location', widget.serviceData['location'] ?? 'N/A', isLink: true),
        _buildInfoRow('Client Name', widget.serviceData['client_name'] ?? 'N/A'),
        SizedBox(height: 20),
        _buildContactButtons(),
      ],
    );
  }

  Widget _buildContactButtons() {
    String phoneNumber = widget.serviceData['contact_no'] ?? '';
    bool hasPhoneNumber = phoneNumber.isNotEmpty && phoneNumber != 'N/A';

    if (!hasPhoneNumber) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(
              'No contact number available',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001E62),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _makePhoneCall,
                icon: Icon(Icons.call, color: Colors.white, size: 20),
                label: Text(
                  'Call',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _sendSMS,
                icon: Icon(Icons.message, color: Colors.white, size: 20),
                label: Text(
                  'SMS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openWhatsApp,
                icon: Icon(Icons.whatshot, color: Colors.white, size: 20),
                label: Text(
                  'WhatsApp',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF25D366),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF001E62).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF001E62),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001E62),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isLink ? Color(0xFF001E62) : Colors.grey[900],
                fontWeight: FontWeight.w600,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.status.toLowerCase() == 'completed') {
      return Container(); // No action buttons for completed services
    }

    return Column(
      children: [
        if (widget.status.toLowerCase() == 'pending')
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _acceptRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Accepting...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Accept Request',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Handle track location
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening location...'),
                  backgroundColor: Color(0xFF001E62),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF001E62),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  widget.status.toLowerCase() == 'pending' ? 'View Location' : 'Track Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
} 