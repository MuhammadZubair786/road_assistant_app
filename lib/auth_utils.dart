import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'LoginOnly.dart';

class AuthUtils {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if user is currently logged in
  static Future<bool> isUserLoggedIn() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Also check if user data is stored in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isUserStored = prefs.getBool("User") ?? false;
        String? userType = prefs.getString("userType");
        String? uid = prefs.getString("uid");
        
        return isUserStored && userType != null && uid != null;
      }
      return false;
    } catch (e) {
      print("Error checking login status: $e");
      return false;
    }
  }

  // Get current user type
  static Future<String?> getCurrentUserType() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString("userType");
    } catch (e) {
      print("Error getting user type: $e");
      return null;
    }
  }

  // Get current user UID
  static Future<String?> getCurrentUserUid() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString("uid");
    } catch (e) {
      print("Error getting user UID: $e");
      return null;
    }
  }

  // Check authentication and redirect to login if needed
  static Future<bool> checkAuthAndRedirect(BuildContext context) async {
    bool isLoggedIn = await isUserLoggedIn();
    
    if (!isLoggedIn) {
      // Show dialog to inform user they need to login
      bool shouldLogin = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.login,
                  color: Color(0xFF001E62),
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Login Required',
                  style: TextStyle(
                    color: Color(0xFF001E62),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Text(
              'You need to login to access this feature. Would you like to login now?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF001E62),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ) ?? false;

      if (shouldLogin) {
        // Navigate to login page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => loginOnly()),
        );
      }
      
      return false;
    }
    
    return true;
  }

  // Logout user
  static Future<void> logout() async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print("Error during logout: $e");
    }
  }
} 