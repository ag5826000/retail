import 'package:flutter/material.dart';
import 'package:shop_app/components/coustom_bottom_nav_bar.dart';
import 'package:shop_app/enums.dart';

import '../../size_config.dart';
import 'components/body.dart';

class HomeScreen extends StatelessWidget {
  static String routeName = "/home";
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    DateTime? rangeStart = args?['rangeStart'];
    DateTime? rangeEnd = args?['rangeEnd'];

    // If rangeStart is not set, set it to a week before the current date
    if (rangeStart == null) {
      rangeStart = DateTime.now().subtract(Duration(days: 7));
    }

    // If rangeEnd is not set, set it to the current date
    if (rangeEnd == null) {
      rangeEnd = DateTime.now();
    }

    print(rangeStart);
    print(rangeEnd);

    return Scaffold(
      body: Body(rangeStart: rangeStart,
        rangeEnd: rangeEnd),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Add your code to open the QR code scanner here.
      //     // You can use Navigator.push to navigate to the scanner screen.
      //   },
      //   child: Icon(
      //     Icons.qr_code,
      //     size: 36,// Adjust the icon size
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
