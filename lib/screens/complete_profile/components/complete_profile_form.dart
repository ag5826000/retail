import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_surfix_icon.dart';
import 'package:shop_app/components/default_button.dart';
import 'package:shop_app/components/form_error.dart';
import 'package:shop_app/screens/home/home_screen.dart';
import 'package:shop_app/screens/otp/otp_screen.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class CompleteProfileForm extends StatefulWidget {
  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? businessName;
  String? ownerName;
  String? aadharNumber;
  String? address;
  String? pincode;

  void addError({String? error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  bool isValidPincode(String pincode) {
    return RegExp(r"^\d{6}$").hasMatch(pincode);
  }

  bool isValidAadhar(String aadhar) {
    return RegExp(r"^\d{12}$").hasMatch(aadhar);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // buildOwnerNameFormField(),
          // SizedBox(height: getProportionateScreenHeight(30)),
          buildBusinessNameFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          // buildAadharNumberFormField(),
          // SizedBox(height: getProportionateScreenHeight(30)),
          // buildAddressFormField(),
          // SizedBox(height: getProportionateScreenHeight(30)),
          buildPincodeFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
          DefaultButton(
            text: "Continue",
            press: () async {
              if (_formKey.currentState!.validate()) {
                final User? user = _auth.currentUser;

                if (user != null) {
                  // Add user details to Firestore
                  await _firestore.collection('users').doc(user.uid).set({
                    'businessName': businessName,
                    //'name': ownerName,
                    //'aadharNumber': aadharNumber,
                    //'address': address,
                    'pincode': pincode,
                  });

                  Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildPincodeFormField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      onSaved: (newValue) {
        setState(() {
          pincode=newValue;
        });
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: "Please Enter your Pincode");
          if (isValidPincode(value)) {
            // Remove the Aadhar format error if it was displayed
            removeError(error: "Please Enter a valid 6-digit Pincode");
            setState(() {
              pincode=value;
            });
          }
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: "Please Enter your Pincode");
          return "";
        } else if (!isValidPincode(value)) {
          addError(error: "Please Enter a valid 6-digit Pincode");
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Pincode",
        hintText: "Enter your pincode",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
      ),
    );
  }

  TextFormField buildAddressFormField() {
    return TextFormField(
      onSaved: (newValue) {
        setState(() {
          address=newValue;
        });
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kAddressNullError);
          setState(() {
            address=value;
          });
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kAddressNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Address",
        hintText: "Enter your address",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
      ),
    );
  }

  TextFormField buildAadharNumberFormField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      onSaved: (newValue) {
        setState(() {
          aadharNumber=newValue;
        });
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: "Please Enter your Aadhar Number");
          if (isValidAadhar(value)) {
            // Remove the Aadhar format error if it was displayed
            setState(() {
              aadharNumber=value;
            });
            removeError(error: "Please Enter a valid 12-digit Aadhar Number");
          }
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: "Please Enter your Aadhar Number");
          return "";
        } else if (!isValidAadhar(value)) {
          addError(error: "Please Enter a valid 12-digit Aadhar Number");
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Aadhar Number",
        hintText: "Enter your Aadhar number",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/ID.svg"),
      ),
    );
  }

  TextFormField buildOwnerNameFormField() {
    return TextFormField(
      onSaved: (newValue) {
        setState(() {
          ownerName=newValue;
        });
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: "Please Enter your Name");
          setState(() {
            ownerName=value;
          });
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: "Please Enter your Name");
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Name",
        hintText: "Enter Business owner's name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildBusinessNameFormField() {
    return TextFormField(
      onSaved: (newValue) {
        setState(() {
          businessName=newValue;
        });
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: "Please Enter Business Name");
          setState(() {
            businessName=value;
          });
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: "Please Enter Business Name");
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Business Name",
        hintText: "Enter the business name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Shop Icon Black.svg"),
      ),
    );
  }
}
