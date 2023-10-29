import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_surfix_icon.dart';
import 'package:shop_app/components/default_button.dart';
import 'package:shop_app/components/form_error.dart';
import 'package:shop_app/screens/complete_profile/complete_profile_screen.dart';

import '../../../constants.dart';
import '../../../helper/firebase_auth_service.dart';
import '../../../size_config.dart';
import '../../otp/otp_screen.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String? phoneNumber;
  final List<String?> errors = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String countryCode = "+91";
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool isGeneratingOTP = false;


  Future<void> _generateOTP() async {
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) {
      // Handle the sign-in using the credential
      // You can navigate to the next screen here if needed
          setState(() {
            isGeneratingOTP = false;
          });
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
        addError(error: "Invalid Phone Number");
      } else if (e.code == 'too-many-requests') {
        addError(error: "Too many verification requests.");
      } else {
        addError(error: "Sorry, an error occurred.");
      }
      setState(() {
        isGeneratingOTP = false;
      });
      // Handle other error cases if needed
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) {
          setState(() {
            errors.clear();
            isGeneratingOTP = false;
          });
          Navigator.pushNamed(context, OtpScreen.routeName,   arguments: {'phoneNumber': phoneNumber, 'verificationId': verificationId},
          );
      // Navigator.pushNamed(context, '/otp_screen', arguments: verificationId);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      // Auto-retrieval of the SMS code timed out (e.g., user didn't receive it)
    };

    setState(() {
      isGeneratingOTP = true;
    });

    await _authService.sendOTP(
      countryCode + phoneNumber!,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
    // Set the isGeneratingOTP flag to false after OTP generation


  }

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildPhoneNumberFormField(),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
          // Replace the "Continue" button with buildGenerateOTPButton
          if (isGeneratingOTP)
            CircularProgressIndicator()
          else
            DefaultButton(
              text: "Continue",
              press: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _generateOTP();
                }
              },
            ),
        ],
      ),
    );
  }

  TextFormField buildPhoneNumberFormField() {
     // Change this to your desired country code
    return TextFormField(
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phoneNumber = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: "Please Enter your Phone Number");
        }
        phoneNumber = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: "Please Enter your Phone Number");
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Phone Number",
        hintText: "Enter your phone number",
        prefixText: countryCode + "  ", // Add the country code as a prefix
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }
}
