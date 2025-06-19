import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:roadside_assistance/User%20Side/Register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Company Side/Tabbar.dart';
import 'User Side/home_screen.dart';
import 'VerificationScreen.dart';
import 'package:animate_do/animate_do.dart';

class loginOnly extends StatefulWidget {
  const loginOnly({super.key});
  @override
  State<loginOnly> createState() => _LoginOnlyState();
}

class _LoginOnlyState extends State<loginOnly> {
  bool _isObscure = true;
  bool _isLoading = false;
  String userType = "User";
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email and password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print("User logged in with UID: $uid");

      // Fetch user details from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      DocumentSnapshot companyDoc =
          await FirebaseFirestore.instance.collection('Company').doc(uid).get();

      DocumentSnapshot? foundDoc;
      if (userDoc.exists) {
        foundDoc = userDoc;
      } else if (companyDoc.exists) {
        foundDoc = companyDoc;
      }

      if (foundDoc == null) {
        print("User document does not exist in Firestore");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not found in database"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      var userData = foundDoc.data() as Map<String, dynamic>?; // Safe casting
      if (userData == null || !userData.containsKey('userType')) {
        print("Firestore document found, but 'userType' field is missing!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account error: 'userType' field missing."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String userType = userData['userType'];
      print("User type retrieved: $userType");

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("User", true);
      await prefs.setString("userType", userType);
      await prefs.setString("uid", uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login successful."),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate based on user type
      if (userType == "User") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      } else if (userType == "Company") {
        _getCompanyLocationAndLogin(userCredential);
      } else {
        print("Invalid 'userType' value in Firestore: $userType");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid 'userType' in database."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCompanyLocationAndLogin(
      UserCredential userCredential) async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location services are disabled."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location permission denied."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permission is permanently denied."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      // Get current position
      // Position position = await Geolocator.getCurrentPosition(
      //     desiredAccuracy: LocationAccuracy.low);
      // print("Company Location: ${position.latitude}, ${position.longitude}");
      // // Get address from coordinates
      // List<Placemark> placemarks =
      //     await placemarkFromCoordinates(position.latitude, position.longitude);
      // Placemark place = placemarks.first;
      // // Format the addressString companyAddress
      // String companyAddress =
      //     " ${place.name ?? 'Unknown Locality'},  ${place.locality ?? 'Unknown Locality'}, ${place.country ?? 'Unknown Country'}";
      // print("Company Address: 123");
      // Navigate to HomeTab with the address

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Hometab(companyAddress: "usa"),
        ),
        (route) => false,
      );
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to retrieve location: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: Stack(
          children: [
            // Centered logo overlapping header and card
            Positioned(
              top: 170,
              left: 0,
              right: 0,
              child: FadeIn(
                duration: const Duration(milliseconds: 800),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/HelpSupport.png',
                          fit: BoxFit.contain,
                          height: 60,
                          width: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                // Gradient header with rounded bottom
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF001E62), Color(0xFF3A7BD5)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 90),
                // Subtitle under logo
                
                // Login form card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: FadeIn(
                      duration: const Duration(milliseconds: 1000),
                      child: Column(
                        children: [
                           Center(
                                    child: const Text(
                                      'Eezee Tow',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            margin: const EdgeInsets.only(top: 24),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email
                                  const Text(
                                    "Email",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      hintText: "Enter your Email",
                                      prefixIcon: Icon(Icons.email, color: Color(0xFF001E62)),
                                      filled: true,
                                      fillColor: Color(0xFFF5F6FA),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: !_isLoading,
                                  ),
                                  const SizedBox(height: 18),
                                  // Password
                                  const Text(
                                    "Password",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _isObscure,
                                    decoration: InputDecoration(
                                      hintText: "Enter your Password",
                                      prefixIcon: Icon(Icons.lock, color: Color(0xFF001E62)),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isObscure ? Icons.visibility_off : Icons.visibility,
                                          color: Color(0xFF3A7BD5),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isObscure = !_isObscure;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: Color(0xFFF5F6FA),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    enabled: !_isLoading,
                                  ),
                                  const SizedBox(height: 8),
                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => VerificationScreen()),
                                              );
                                            },
                                      child: const Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          color: Color(0xFF001E62),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF001E62),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              "Log In",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: 'Montserrat',
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Sign Up Link
                          Center(
                            child: GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => RegistrationScreen()),
                                      );
                                    },
                              child: const Text.rich(
                                TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign Up",
                                      style: TextStyle(
                                        color: Color(0xFF001E62),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
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
            // Loading overlay
            // if (_isLoading)
            //   Positioned.fill(
            //     child: Container(
            //       color: Colors.black.withOpacity(0.1),
            //       child: const Center(
            //         child: CircularProgressIndicator(
            //           color: Color(0xFF001E62),
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
