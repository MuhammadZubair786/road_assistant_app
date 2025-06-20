import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'location_picker.dart';
import 'issue_details.dart';

class PersonalIdentity extends StatefulWidget {
  @override
  _PersonalIdentityState createState() => _PersonalIdentityState();
}

class _PersonalIdentityState extends State<PersonalIdentity> {
  bool isPressed = false;
  final TextEditingController branchController = TextEditingController();
  final TextEditingController branchAddressController = TextEditingController();
  final TextEditingController employeesController = TextEditingController();
  final TextEditingController legalNumberController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  LatLng? selectedLocation;
  File? _selectedFile;
  String? uploadedFileUrl;
  var userdata;

  // Function to select location
  Future<void> _pickLocation() async {
    LatLng? location = await Navigator.push(
      context as BuildContext,
      MaterialPageRoute(builder: (context) => LocationPicker()),
    );
    if (location != null) {
      setState(() {
        selectedLocation = location;
      });

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (placemarks.isNotEmpty) {
          setState(() {
            locationController.text =
                "${placemarks.first.street}, ${placemarks.first.locality}";
          });

          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            SnackBar(
              content: Text("Location selected successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print("Error fetching address: $e");
      }
    }
  }

  // Function to upload file to Cloudinary
  Future<void> _uploadToCloudinary(File file) async {
    String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dgbjqewiy/upload";
    String uploadPreset = "imageuplaod";
    var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = jsonDecode(await response.stream.bytesToString());
      setState(() {
        uploadedFileUrl = responseData['secure_url'];
      });
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text("File uploaded successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text("File upload failed!")),
      );
    }
  }

  // Function to select file
  Future<void> _pickFile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
      _uploadToCloudinary(_selectedFile!);
    }
  }

  // Save data to Firestore
  Future<void> _saveDataToFirestore() async {
    if (branchController.text.isEmpty ||
        branchAddressController.text.isEmpty ||
        employeesController.text.isEmpty ||
        legalNumberController.text.isEmpty ||
        selectedLocation == null) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Please fill in all fields before submitting!')),
      );
      return;
    }
    CollectionReference users =
        FirebaseFirestore.instance.collection('Personal_identity');
    await users.add({
      'branch': branchController.text,
      'branchAddress': branchAddressController.text,
      'employees': employeesController.text,
      'legalNumber': legalNumberController.text,
      'location': {
        'lat': selectedLocation!.latitude,
        'lng': selectedLocation!.longitude
      },
      'locationAddress': locationController.text,
      'legalizationLetter': uploadedFileUrl,
    });
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text('Data saved successfully!')),
    );
  }

  void initState() {
    super.initState();
    getCompanyByAccount();
  }

  Future<void> getCompanyByAccount() async {
    final doc = await FirebaseFirestore.instance
        .collection('Company')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (doc.exists) {
      print(doc.data());
      userdata = doc.data();
      setState(() {});
    } else {
      print('No document found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.grey[50],
      body: userdata == null
          ? Container(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF001E62)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Loading profile...",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Modern Header
                  Container(
                    padding: EdgeInsets.all(20),
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
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // IconButton(
                            //   icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                            //   onPressed: () => Navigator.pop(context),
                            // ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Company Profile",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Your business information and details",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  // Profile Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Profile Image Section
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFF001E62).withOpacity(0.2),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: userdata["imageUrl"] != null && userdata["imageUrl"].isNotEmpty
                                        ? Image.network(
                                            userdata["imageUrl"],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[100],
                                                child: Icon(
                                                  Icons.business,
                                                  size: 40,
                                                  color: Color(0xFF001E62).withOpacity(0.5),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey[100],
                                            child: Icon(
                                              Icons.business,
                                              size: 40,
                                              color: Color(0xFF001E62).withOpacity(0.5),
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  userdata["name"] ?? "Company Name",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF001E62),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  userdata["userType"] ?? "Company",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Company Information Section
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                                        Icons.info_outline,
                                        color: Color(0xFF001E62),
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Company Information",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF001E62),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),
                                
                                // Business Name
                                _buildInfoRow(
                                  icon: Icons.business,
                                  label: "Business Name",
                                  value: userdata["name"] ?? "Not provided",
                                ),
                                
                                Divider(height: 32, color: Colors.grey[200]),
                                
                                // Address
                                _buildInfoRow(
                                  icon: Icons.location_on,
                                  label: "Address",
                                  value: userdata["address"] ?? "Not provided",
                                ),
                                
                                Divider(height: 32, color: Colors.grey[200]),
                                
                                // Contact
                                _buildInfoRow(
                                  icon: Icons.phone,
                                  label: "Contact",
                                  value: userdata["contact"] ?? "Not provided",
                                ),
                                
                                Divider(height: 32, color: Colors.grey[200]),
                                
                                // Account Type
                                _buildInfoRow(
                                  icon: Icons.account_circle,
                                  label: "Account Type",
                                  value: userdata["userType"] ?? "Company",
                                ),
                              ],
                            ),
                          ),
                          
                          // SizedBox(height: 24),
                          
                          // // Action Buttons
                          // Container(
                          //   padding: EdgeInsets.all(24),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(20),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.black.withOpacity(0.05),
                          //         blurRadius: 10,
                          //         offset: Offset(0, 4),
                          //       ),
                          //     ],
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Row(
                          //         children: [
                          //           Container(
                          //             padding: EdgeInsets.all(8),
                          //             decoration: BoxDecoration(
                          //               color: Color(0xFF001E62).withOpacity(0.1),
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //             child: Icon(
                          //               Icons.settings,
                          //               color: Color(0xFF001E62),
                          //               size: 24,
                          //             ),
                          //           ),
                          //           SizedBox(width: 12),
                          //           // Text(
                          //           //   "Quick Actions",
                          //           //   style: TextStyle(
                          //           //     fontSize: 20,
                          //           //     fontWeight: FontWeight.bold,
                          //           //     color: Color(0xFF001E62),
                          //           //   ),
                          //           // ),
                          //         ],
                          //       ),
                          //       // SizedBox(height: 24),
                                
                          //       // // Edit Profile Button
                          //       // Container(
                          //       //   width: double.infinity,
                          //       //   child: ElevatedButton.icon(
                          //       //     onPressed: () {
                          //       //       // Navigate to edit profile page
                          //       //     },
                          //       //     icon: Icon(Icons.edit, color: Colors.white),
                          //       //     label: Text(
                          //       //       "Edit Profile",
                          //       //       style: TextStyle(
                          //       //         fontSize: 16,
                          //       //         fontWeight: FontWeight.w600,
                          //       //         color: Colors.white,
                          //       //       ),
                          //       //     ),
                          //       //     style: ElevatedButton.styleFrom(
                          //       //       backgroundColor: Color(0xFF001E62),
                          //       //       padding: EdgeInsets.symmetric(vertical: 16),
                          //       //       shape: RoundedRectangleBorder(
                          //       //         borderRadius: BorderRadius.circular(12),
                          //       //       ),
                          //       //       elevation: 0,
                          //       //     ),
                          //       //   ),
                          //       // ),
                                
                          //       // SizedBox(height: 16),
                                
                          //       // // View Services Button
                          //       // Container(
                          //       //   width: double.infinity,
                          //       //   child: ElevatedButton.icon(
                          //       //     onPressed: () {
                          //       //       Navigator.push(
                          //       //         context,
                          //       //         MaterialPageRoute(
                          //       //           builder: (context) => IssueDetails(
                          //       //             requestData: {},
                          //       //           ),
                          //       //         ),
                          //       //       );
                          //       //     },
                          //       //     icon: Icon(Icons.visibility, color: Color(0xFF001E62)),
                          //       //     label: Text(
                          //       //       "View Services",
                          //       //       style: TextStyle(
                          //       //         fontSize: 16,
                          //       //         fontWeight: FontWeight.w600,
                          //       //         color: Color(0xFF001E62),
                          //       //       ),
                          //       //     ),
                          //       //     style: ElevatedButton.styleFrom(
                          //       //       backgroundColor: Colors.white,
                          //       //       padding: EdgeInsets.symmetric(vertical: 16),
                          //       //       shape: RoundedRectangleBorder(
                          //       //         borderRadius: BorderRadius.circular(12),
                          //       //         side: BorderSide(color: Color(0xFF001E62), width: 2),
                          //       //       ),
                          //       //       elevation: 0,
                          //       //     ),
                          //       //   ),
                          //       // ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
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
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildArrowButton(
    BuildContext context, IconData icon, Color bgColor, Color iconColor) {
  return Container(
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: IconButton(
      icon: Icon(icon, color: iconColor),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => IssueDetails(
                    requestData: {},
                  )),
        );
      },
    ),
  );
}

Widget RowData(String label, String value) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            value,
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTextField(String label, TextEditingController controller) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: TextField(
        controller: controller, decoration: InputDecoration(labelText: label)),
  );
} 