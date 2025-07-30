import 'package:roadside_assistance/Company%20Side/Location_Picker.dart';
import 'package:roadside_assistance/Company%20Side/issue_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roadside_assistance/LoginOnly.dart';
import 'CompanyFeedbackScreen.dart';
import 'CompanyNotification.dart';
import '../User Side/Register.dart';
import 'ServiceProvide.dart';
import 'Tabbar.dart';
import 'Track.dart';
import '../HelpSupportScreen.dart';
import '../User Side/Settings.dart';

class CompanyDrawer extends StatefulWidget {
  const CompanyDrawer({super.key});

  @override
  _CompanyDrawerState createState() => _CompanyDrawerState();
}

class _CompanyDrawerState extends State<CompanyDrawer> {
  String companyName = "Loading...";
  String companyEmail = "Loading...";
  String profileImage = ""; // Default is empty, fallback to placeholder
  @override
  void initState() {
    super.initState();
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Company')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          companyName = doc['name'] ?? "No Name";
          companyEmail = user.email ?? "No Email";
          profileImage = doc['imageUrl'] ?? ""; // Cloudinary Image URL
        });
      }
    } catch (e) {
      print("Error fetching company data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF001E62), // Dark blue background
        child: Column(
          children: [
            // 🔹 **Header Section**
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF001E62),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : const AssetImage('assets/profile_image.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    companyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    companyEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 **Menu Items Section**
            Expanded(
              child: ListView(
                children: [
                  buildMenuItem(
                    context,
                    iconPath: 'assets/dashboard.png',
                    title: "Dashboard",
                    destination: Hometab(
                      companyAddress: '',
                    ),
                  ),
                  buildMenuItem(
                    context,
                    iconPath: 'assets/service_request.png',
                    title: "Service Requests",
                    destination: ServiceProvide(),
                  ),
                  // buildMenuItem(
                  //   context,
                  //   iconPath: 'assets/client_issue.png',
                  //   title: "Client Issue Details",
                  //   destination: IssueDetails(
                  //     requestData: {},
                  //   ),
                  // ),
                  // buildMenuItem(
                  //   context,
                  //   iconPath: 'assets/manage_loc.png',
                  //   title: "Manage Locations",
                  //   destination: LocationPicker(),
                  // ),
                  buildMenuItem(
                    context,
                    iconPath: 'assets/service_his.png',
                    title: "Service History",
                    destination: Track(),
                  ),
                  buildMenuItem(
                    context,
                    iconPath: 'assets/notification2.png',
                    title: "Notifications",
                    destination: CompanyNotificationsScreen(),
                  ),
                  buildMenuItem(
                    context,
                    iconPath: 'assets/account_set.png',
                    title: "Account Settings",
                    destination:SettingScreen(),
                  ),
                  buildMenuItem(
                    context,
                    iconPath: 'assets/client_issue.png',
                    title: "Feedback",
                    destination: CompanyFeedbackScreen(),
                  ),
                  buildMenuItem(
                    context,
                    iconPath: 'assets/HelpSupport.png',
                    title: "Help & Support",
                    destination: HelpSupportScreen(),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Image.asset('assets/log-out.png', width: 24),
                    ),
                    title: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ **Reusable Method for Menu Items**
  Widget buildMenuItem(
    BuildContext context, {
    required String iconPath,
    required String title,
    required Widget destination,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Image.asset(iconPath, width: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }

  // ✅ **Logout Confirmation Dialog**
  void _showLogoutDialog(BuildContext context) {
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
                  child: Icon(Icons.logout, color: primaryColor, size: 38),
                ),
                const SizedBox(height: 18),
                Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to logout?",
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
                          FirebaseAuth.instance.signOut();
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => loginOnly()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Yes, Logout",
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
