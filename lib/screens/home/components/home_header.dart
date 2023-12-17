import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/screens/cart/cart_screen.dart';
import 'package:shop_app/screens/home/components/calender.dart';
import '../../../size_config.dart';
import 'icon_btn_with_counter.dart';

class HomeHeader extends StatefulWidget {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  const HomeHeader({Key? key, this.rangeStart, this.rangeEnd}) : super(key: key);

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String _formattedDate(DateTime? date) {
    if (date != null) {
      return DateFormat('MM/dd/yyyy').format(date);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(1)),
      child: Container(
        height: getProportionateScreenHeight(80),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your logo here
            // Image.asset(
            //   'assets/icons/playstore.png', // Adjust the path to your logo image
            //   height: getProportionateScreenHeight(70), // Adjust the height as needed
            // ),

            SizedBox(width: 4),

            GestureDetector(
              onTap: () {
                // Handle calendar icon press action
                Navigator.pushNamed(context, Calender.routeName, arguments: {'sourcePage': 'home'});
              },
              child: IconBtnWithCounter(
                svgSrc: "assets/icons/calender.svg",
                press: () => Navigator.pushNamed(context, Calender.routeName, arguments: {'sourcePage': 'home'}),
              ),
            ),

            if (widget.rangeStart != null && widget.rangeEnd != null)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 1), // Add margin to separate widgets
                child: Text(
                  '${_formattedDate(widget.rangeStart)} - ${_formattedDate(widget.rangeEnd)}',
                  style: TextStyle(fontSize: 16),
                ),
              ),

            // SizedBox(width: 2),

            // GestureDetector(
            //   onTap: () {
            //     // Handle cart icon press action
            //     Navigator.pushNamed(context, CartScreen.routeName);
            //   },
            //   child: IconBtnWithCounter(
            //     svgSrc: "assets/icons/Cart Icon.svg",
            //     press: () => Navigator.pushNamed(context, CartScreen.routeName),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
