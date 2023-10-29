import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/components/default_button.dart';
import 'package:shop_app/screens/wrapper/wrapper.dart';
import 'package:shop_app/size_config.dart';

import '../../../constants.dart';

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
  bool isWrongOTP =false;

  FocusNode? pin2FocusNode;
  FocusNode? pin3FocusNode;
  FocusNode? pin4FocusNode;
  FocusNode? pin5FocusNode;
  FocusNode? pin6FocusNode;

  String? pin1;
  String? pin2;
  String? pin3;
  String? pin4;
  String? pin5;
  String? pin6;

  @override
  void initState() {
    super.initState();
    isVerifyingOTP = false;
    isWrongOTP =false;
    pin2FocusNode = FocusNode();
    pin3FocusNode = FocusNode();
    pin4FocusNode = FocusNode();
    pin5FocusNode = FocusNode();
    pin6FocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    pin2FocusNode!.dispose();
    pin3FocusNode!.dispose();
    pin4FocusNode!.dispose();
    pin5FocusNode!.dispose();
    pin6FocusNode!.dispose();
  }

  void nextField(String value, FocusNode? focusNode) {
    if (value.length == 1) {
      focusNode!.requestFocus();
    }
  }

  Future<void> verifyOTP() async {
    final String? code =pin1!+pin2!+pin3!+pin4!+pin5!+pin6!;
    print(code);
    try {
      setState(() {
        isVerifyingOTP = true;
        isWrongOTP=false;
      });
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, // Retrieve the verification ID from the previous screen
        smsCode: code!,
      );
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // OTP is correct, you can navigate to the next screen.
        print("Logged in with user: ${user.uid}");
        Navigator.pushReplacementNamed(context, WrapperScreen.routeName);
        setState(() {
          isVerifyingOTP = false;
        });
      }
    } catch (e) {
      setState(() {
        isVerifyingOTP = false;
        isWrongOTP=true;
      });
      // OTP verification failed
      print("Failed to verify OTP: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: getProportionateScreenWidth(50),
                child: TextFormField(
                  autofocus: true,
                  obscureText: true,
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    nextField(value, pin2FocusNode);
                    setState(() {
                      pin1=value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(50),
                child: TextFormField(
                  focusNode: pin2FocusNode,
                  obscureText: true,
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    nextField(value, pin3FocusNode);
                    setState(() {
                      pin2=value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(50),
                child: TextFormField(
                  focusNode: pin3FocusNode,
                  obscureText: true,
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    nextField(value, pin4FocusNode);
                    setState(() {
                      pin3=value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(50),
                child: TextFormField(
                  focusNode: pin4FocusNode,
                  obscureText: true,
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    nextField(value, pin5FocusNode);
                    setState(() {
                      pin4=value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(50),
                child: TextFormField(
                  focusNode: pin5FocusNode,
                  obscureText: true,
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    nextField(value, pin6FocusNode);
                    setState(() {
                      pin5=value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(50),
                child: TextFormField(
                  focusNode: pin6FocusNode,
                  obscureText: true,
                  style: TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    if (value.length == 1) {
                      pin6FocusNode!.unfocus();
                      setState(() {
                        pin6=value;
                      });
                      verifyOTP();
                      // Then you need to check is the code is correct or not
                    }
                  },
                ),
              ),

            ],
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.15),
          if(isWrongOTP)
            Text(
              'Incorrect OTP. Please try again.',
              style: TextStyle(
                color: Colors.red, // You can customize the color
              ),
            ),
          if(isWrongOTP)
            SizedBox(height: getProportionateScreenHeight(20)),
          if (isVerifyingOTP)
            CircularProgressIndicator()
          else
            DefaultButton(
              text: "Continue",
              press: () {
                verifyOTP();
              },
          )
        ],
      ),
    );
  }
}
