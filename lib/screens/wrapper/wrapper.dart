import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_app/screens/home/home_screen.dart';

import '../../size_config.dart';
import '../complete_profile/complete_profile_screen.dart';

class WrapperScreen extends StatefulWidget {
  static String routeName = "/wrapper";
  @override
  _WrapperScreenState createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    checkUserProfile();
  }

  Future<void> checkUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    final QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, isEqualTo: user!.uid)
        .get();

    if (userQuery.docs.isEmpty) {
      // If no user data is found, navigate to the "Update Profile" screen
      Navigator.pushReplacementNamed(context, CompleteProfileScreen.routeName); // Replace with your named route
    } else {
      // Navigate to the "Home" screen
      Navigator.pushReplacementNamed(context, HomeScreen.routeName); // Replace with your named route
    }

    // Set isLoading to false after the query is complete
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show the loading indicator
            : SizedBox.shrink(), // Hide the loading indicator when not loading
      ),
    );
  }
}
