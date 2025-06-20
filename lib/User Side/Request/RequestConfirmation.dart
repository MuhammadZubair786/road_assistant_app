import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'GetService.dart';

class RequestConfirmation extends StatefulWidget {
  const RequestConfirmation({super.key});

  @override
  State<RequestConfirmation> createState() => _RequestConfirmationState();
}

class _RequestConfirmationState extends State<RequestConfirmation> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController carNoController = TextEditingController();
  final TextEditingController carColorController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();

  bool isFormValid = false;
  String selectedService = "Loading...";
  String selectedVehicle = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchSelectedData();
  }

  Future<void> fetchSelectedData() async {
    try {
      DocumentSnapshot serviceDoc = await FirebaseFirestore.instance
          .collection('userSelectedService')
          .doc('currentService')
          .get();

      if (serviceDoc.exists) {
        setState(() {
          selectedService = serviceDoc['service'] ?? "Unknown Service";
          selectedVehicle = serviceDoc['vehicle'] ?? "Unknown Vehicle";
        });
      }
    } catch (e) {
      print("Error fetching service: $e");
    }
  }

  void checkFormValid() {
    setState(() {
      isFormValid = carNoController.text.isNotEmpty &&
          carColorController.text.isNotEmpty &&
          locationController.text.isNotEmpty &&
          detailsController.text.isNotEmpty &&
          contactNoController.text.isNotEmpty;
    });
  }

  Future<void> saveRequestToFirestore() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User is not logged in");
      }

      final docRef = await FirebaseFirestore.instance.collection('requests').add({
        'user_id': userId,
        'car_no': carNoController.text,
        'car_color': carColorController.text,
        'location': locationController.text,
        'details': detailsController.text,
        'contact_no': contactNoController.text,
        'selected_service': selectedService,
        'selected_vehicle': selectedVehicle,
        'timestamp': FieldValue.serverTimestamp(),
      });

      String docId = docRef.id;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request Submitted Successfully"),
          backgroundColor: Color(0xFF001E62),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GetServices(docid: docId)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceInfo(),
                      _buildFormSections(),
                    ],
                  ),
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF001E62),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Expanded(
                child: Text(
                  "Request Details",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 24), // For balance
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF001E62),
            const Color(0xFF001E62).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001E62).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.build_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            selectedService,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedVehicle,
                  style: const TextStyle(
                    color: Colors.white,
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

  Widget _buildFormSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSection(
            "Vehicle Details",
            Icons.directions_car_rounded,
            [
              _buildInputField("Vehicle Number", carNoController),
              _buildInputField("Vehicle Color", carColorController),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            "Location",
            Icons.location_on_rounded,
            [
              _buildInputField("Enter Location", locationController),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            "Issue Details",
            Icons.description_rounded,
            [
              _buildInputField(
                "Describe the issue in detail",
                detailsController,
                maxLines: 4,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            "Contact Information",
            Icons.phone_rounded,
            [
              _buildInputField(
                "Contact Number",
                contactNoController,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF001E62).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF001E62),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001E62),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: (value) => checkFormValid(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF001E62),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF001E62),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: maxLines > 1 ? 20 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isFormValid ? saveRequestToFirestore : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF001E62),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isFormValid ? "Submit Request" : "Fill All Fields",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (isFormValid) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
