import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/components/default_button.dart';
import 'package:shop_app/screens/home/home_screen.dart';
import 'package:shop_app/size_config.dart';
import 'package:shop_app/screens/wrapper/wrapper.dart';
import '../../../constants.dart';

// Import your wrapper file

class OtpForm extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpForm({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
  }) : super(key: key);

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  bool isVerifyingOTP = false;
  bool isWrongOTP = false;
  String? otp;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.15),
          SizedBox(
            width: getProportionateScreenWidth(300), // Adjust the width as needed
            child: TextFormField(
              obscureText: true,
              style: TextStyle(fontSize: 24),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6, // Set maximum length to 6
              decoration: otpInputDecoration,
              onChanged: (value) {
                if (value.length <= 6) {
                  setState(() {
                    otp = value;
                  });
                }
              },
            ),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.15),
          if (isWrongOTP)
            Text(
              'Incorrect OTP. Please try again.',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          if (isWrongOTP) SizedBox(height: getProportionateScreenHeight(20)),
          if (isVerifyingOTP)
            CircularProgressIndicator()
          else
            DefaultButton(
              text: "Continue",
              press: () {
                verifyOTP();
              },
            ),
        ],
      ),
    );
  }

  Future<void> verifyOTP() async {
    try {
      setState(() {
        isVerifyingOTP = true;
        isWrongOTP = false;
      });

      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp!,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        print("Logged in with user: ${user.uid}");
        Navigator.pushReplacementNamed(context, WrapperScreen.routeName);
        setState(() {
          isVerifyingOTP = false;
        });
      }
    } catch (e) {
      setState(() {
        isVerifyingOTP = false;
        isWrongOTP = true;
      });
      print("Failed to verify OTP: $e");
    }
  }
}
