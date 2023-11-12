import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/screens/cart/cart_screen.dart';
import 'package:shop_app/screens/home/components/calender.dart';

import '../../../size_config.dart';
import 'icon_btn_with_counter.dart';
import 'search_field.dart';

class HomeHeader extends StatefulWidget {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  const HomeHeader({
    Key? key,
    this.rangeStart, this.rangeEnd
  }) : super(key: key);

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
      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.rangeStart != null && widget.rangeEnd != null)
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   'Date Range:',
                    //   style: TextStyle(fontSize: 16),
                    // ),
                    // SizedBox(width: 10),
                    Text(
                      '${_formattedDate(widget.rangeStart)} - ${_formattedDate(widget.rangeEnd)}',
                      style: TextStyle(fontSize: 16),

                    ),
                  ],
                ),
              ),
            ),
          SizedBox(width: 10),
          IconBtnWithCounter(
            svgSrc: "assets/icons/Cart Icon.svg",
            press: () => Navigator.pushNamed(context, CartScreen.routeName),
          ),
          SizedBox(width: 10),
          IconBtnWithCounter(
            svgSrc: "assets/icons/calender.svg",
            press: () => Navigator.pushNamed(context, Calender.routeName),
          ),
        ],
      ),
    );
  }
}