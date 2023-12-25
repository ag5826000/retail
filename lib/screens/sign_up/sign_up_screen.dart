import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/socal_card.dart';
import '../../constants.dart';
import '../../size_config.dart';
import 'components/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  static String routeName = "/sign_up";
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        // title: Text("Sign Up/Login"),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Text("Welcome Saaab!", style: headingStyle),
                  SizedBox(height: 16),
                  Text(
                    "Enter your Phone Number to Login/Signup",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.07),
                  SignUpForm(),
                  SizedBox(height: SizeConfig.screenHeight * 0.08),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SocalCard(
                  //       icon: "assets/icons/google-icon.svg",
                  //       press: () {},
                  //     ),
                  //     SocalCard(
                  //       icon: "assets/icons/facebook-2.svg",
                  //       press: () {},
                  //     ),
                  //     SocalCard(
                  //       icon: "assets/icons/twitter.svg",
                  //       press: () {},
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.caption,
                      children: [
                        TextSpan(
                          text:
                          'By continuing you confirm that you agree \nwith our ',
                        ),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Implement your navigation or open the link action here.
                              _launchURL();
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _launchURL() async {
    final Uri toLaunch =
    Uri(scheme: 'https', host: 'hisaaabcom.notion.site', path: 'Privacy-Policy-b30617f4f2114d4a800229ec8ef095ba/');
    await launchUrl(toLaunch);
  }
}
