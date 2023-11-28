import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/components/default_button.dart';

import '../../../constants.dart';
import '../../../models/Cart.dart';
import '../../../size_config.dart';

typedef CheckoutFunction = void Function(String paymentMethod);

class CheckoutCard extends StatefulWidget {
  final double cartTotal;
  final CheckoutFunction onPressCheckout;
  const CheckoutCard({
    Key? key,
    required this.cartTotal,
    required this.onPressCheckout,
  }) : super(key: key);

  @override
  State<CheckoutCard> createState() => _CheckoutCardState();
}

class _CheckoutCardState extends State<CheckoutCard> {

  void _showCheckoutOptions() {
    if (widget.cartTotal <= 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('No Items in Cart'),
            content: Text('Please add items to the cart before checkout.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select Payment Method'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle checkout with UPI and close the modal sheet
                        widget.onPressCheckout("UPI");
                      },
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.payment),
                            color: Colors.blue, // Color for the payment icon
                            onPressed: () {
                              // Handle checkout with UPI and close the modal sheet
                              widget.onPressCheckout("UPI");
                              Navigator.pop(context);
                            },
                          ),
                          Text('Checkout with UPI', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle checkout with cash and close the modal sheet
                        widget.onPressCheckout("Cash");
                      },
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.money),
                            color: Colors.green, // Color for the money icon
                            onPressed: () {
                              // Handle checkout with cash and close the modal sheet
                              widget.onPressCheckout("Cash");
                              Navigator.pop(context);
                            },
                          ),
                          Text('Checkout with Cash', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: getProportionateScreenWidth(15),
        horizontal: getProportionateScreenWidth(30),
      ),
      // height: 174,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -15),
            blurRadius: 20,
            color: Color(0xFFDADADA).withOpacity(0.15),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  height: getProportionateScreenWidth(40),
                  width: getProportionateScreenWidth(40),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F6F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset("assets/icons/receipt.svg"),
                ),
                Spacer(),
                Text("Add voucher code"),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: kTextColor,
                )
              ],
            ),
            SizedBox(height: getProportionateScreenHeight(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    text: "Total:\n",
                    children: [
                      TextSpan(
                        text: "₹${widget.cartTotal.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(190),
                  child: DefaultButton(
                    text: "Checkout",
                    press: _showCheckoutOptions,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
