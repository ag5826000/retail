import 'package:flutter/material.dart';
import 'package:shop_app/size_config.dart';

import 'components/body.dart';

class OtpScreen extends StatelessWidget {
  static String routeName = "/otp";
  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, String?>?;
    final String phoneNumber = routeArgs?['phoneNumber'] ?? '';
    final String verificationId = routeArgs?['verificationId'] ?? '';
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Verification"),
      ),
      body: Body(phoneNumber: phoneNumber, verificationId: verificationId), // Pass verificationId to Body
    );
  }
}