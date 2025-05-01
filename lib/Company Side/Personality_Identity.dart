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
  final TextEditingController locationController =
      TextEditingController(); // To display selected location
  LatLng? selectedLocation;
  File? _selectedFile;
  String? uploadedFileUrl;
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

          // Show success message in Snackbar
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
    // Check if any required field is empty
    if (branchController.text.isEmpty ||
        branchAddressController.text.isEmpty ||
        employeesController.text.isEmpty ||
        legalNumberController.text.isEmpty ||
        selectedLocation == null) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Please fill in all fields before submitting!')),
      );
      return; // Stop the function from proceeding
    }
    // Reference to Firestore collection
    CollectionReference users =
        FirebaseFirestore.instance.collection('Personal_identity');
    // Add validated data to Firestore
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
      'legalizationLetter': uploadedFileUrl, // Cloudinary uploaded file URL
    });
    // Show success message
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text('Data saved successfully!')),
    );
  }

  void initState() {
    super.initState();
    getCompanyByAccount();
  }

  var userdata;

  Future<void> getCompanyByAccount() async {
    final doc = await FirebaseFirestore.instance
        .collection('Company')
        .doc(FirebaseAuth
            .instance.currentUser!.uid) // only if accountId is the document ID
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF001E62), Colors.white],
              ),
            ),
            child: const Column(
              children: [
                SizedBox(height: 50,),
                Center(
                  child: Text(
                    "Profile Details",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),Center(
            child: CircleAvatar(
              radius: 40, // Fixed size for clean, consistent design
              backgroundImage: NetworkImage(userdata["imageUrl"]),
            ),
          )
,

          RowData("Bussiness Name", userdata["name"]),
          RowData("Address", userdata["address"]),
          RowData("Contact", userdata["contact"]),

          RowData("Account Type", userdata["userType"]),
          // Location Picker
          // TextField(
          //   controller: locationController,
          //   decoration: InputDecoration(
          //     labelText: "Choose Location From map",
          //     prefixIcon: Icon(Icons.home),
          //     suffixIcon: IconButton(
          //       icon: Icon(Icons.location_on, color: Color(0xFF001E62)),
          //       onPressed: _pickLocation,
          //     ),
          //   ),
          // ),

          // _buildTextField("Number of Employees", employeesController),
          // _buildTextField("Legal Number", legalNumberController),
          // // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          //   child: Text('Upload legalization letter here',
          //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          //   child: GestureDetector(
          //     onTap: _pickFile,
          //     child: Container(
          //       height: 50,
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(12),
          //         boxShadow: [
          //           BoxShadow(
          //               color: Colors.grey.withOpacity(0.5),
          //               spreadRadius: 2,
          //               blurRadius: 5,
          //               offset: Offset(0, 3))
          //         ],
          //       ),
          //       child: Center(
          //           child: Text("Choose File",
          //               style: TextStyle(
          //                   fontSize: 16, fontWeight: FontWeight.bold))),
          //     ),
          //   ),
          // ),
          // if (_selectedFile != null)
          //   Padding(
          //       padding: EdgeInsets.all(10),
          //       child: Text("File selected successfully")),

          // SizedBox(height: 50),
          // Center(
          //   child: ElevatedButton(
          //     onPressed: _saveDataToFirestore,
          //     child: Text(
          //       "Submit",
          //       style: TextStyle(
          //           fontSize: 20,
          //           color: Colors.white,
          //           fontWeight: FontWeight.w600),
          //     ),
          //     style:
          //         ElevatedButton.styleFrom(backgroundColor: Color(0xFF001E62)),
          //   ),
          // ),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     // _buildArrowButton(
          //     //     context, Icons.arrow_back, Colors.grey[300]!, Colors.black),
          //     // ✅ Pass context
          //     const SizedBox(width: 10),
          //     _buildArrowButton(context, Icons.arrow_forward,
          //         const Color(0xFF001E62), Colors.white),
          //   ],
          // ),
        ]),
      ),
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
          context, // ✅ Pass the correct context
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
