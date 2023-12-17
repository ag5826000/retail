import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/screens/sign_up/sign_up_screen.dart';

import 'profile_menu.dart';
import 'profile_pic.dart';

class Body extends StatelessWidget {
  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        SignUpScreen.routeName,
            (route) => false, // This removes all routes from the stack
      );
    } catch (e) {
      // Handle sign-out errors here, if any
      print("Error signing out: $e");
    }
  }

  void _showConfirmationDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // ProfilePic(),
          SizedBox(height: 20),
          ProfileMenu(
            text: "My Account",
            icon: "assets/icons/User Icon.svg",
            press: () => _showAccountDetailsDialog(context),
          ),
          // ProfileMenu(
          //   text: "Notifications",
          //   icon: "assets/icons/Bell.svg",
          //   press: () {
          //     // Add logic for Notifications action here (skip pop-up)
          //     print("Notifications action");
          //   },
          // ),
          // ProfileMenu(
          //   text: "Settings",
          //   icon: "assets/icons/Settings.svg",
          //   press: () {
          //     // Add logic for Settings action here (skip pop-up)
          //     print("Settings action");
          //   },
          // ),
          ProfileMenu(
            text: "Help Center",
            icon: "assets/icons/Question mark.svg",
            press: () => _showHelpCenterDialog(context),
          ),
          ProfileMenu(
            text: "Log Out",
            icon: "assets/icons/Log out.svg",
            press: () => _showConfirmationDialog(
              context,
              "Log Out",
              "Are you sure you want to log out?",
                  () {
                _signOut(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountDetailsDialog(BuildContext context) async {
    // Get the current user's UID (User ID) from FirebaseAuth
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        // Fetch user details from Firestore using the UID
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        // Extract user details
        String businessName = userSnapshot['businessName'] ?? 'N/A';
        String pincode = userSnapshot['pincode'] ?? 'N/A';
        String? phoneNumber=FirebaseAuth.instance.currentUser?.phoneNumber;

        // Construct the account details string
        String accountDetails = "Account details:\n\nBusiness Name: $businessName\nPincode: $pincode\nPhone Number: $phoneNumber";

        // Show the information dialog
        _showInformationDialog(context, "My Account", accountDetails);
      } catch (e) {
        print("Error fetching account details: $e");
        // Handle error, show an error dialog, or take appropriate action
      }
    }
  }

  void _showHelpCenterDialog(BuildContext context) {
    // Add logic to fetch and display help center contact information
    String helpCenterInfo = "Help Center contact:\n\nEmail: ag5826000@gmail.com\nPhone: +91 9453134239";
    _showInformationDialog(context, "Help Center", helpCenterInfo);
  }

  void _showInformationDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.orange, // Title text color
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: Colors.black, // Content text color
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.orange, // Button text color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Colors.white, // Dialog background color
          elevation: 5.0, // Elevation of the dialog
        );
      },
    );
  }
}