import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../splash/splash_screen.dart';
import 'profile_menu.dart';
import 'profile_pic.dart';

class Body extends StatelessWidget {

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        SplashScreen.routeName, // Replace with your login or splash screen route
            (route) => false, // This removes all routes from the stack
      );
    } catch (e) {
      // Handle sign-out errors here, if any
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          ProfilePic(),
          SizedBox(height: 20),
          ProfileMenu(
            text: "My Account",
            icon: "assets/icons/User Icon.svg",
            press: () => {},
          ),
          ProfileMenu(
            text: "Notifications",
            icon: "assets/icons/Bell.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Settings",
            icon: "assets/icons/Settings.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Help Center",
            icon: "assets/icons/Question mark.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Log Out",
            icon: "assets/icons/Log out.svg",
            press: () {
              _signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
