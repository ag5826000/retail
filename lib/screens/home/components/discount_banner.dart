import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../size_config.dart';

class DiscountBanner extends StatelessWidget {
  final String? value;
  final String? title;
  const DiscountBanner({Key? key, this.value,this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(getProportionateScreenWidth(7)),
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(20),
        vertical: getProportionateScreenWidth(15),
      ),
      decoration: BoxDecoration(
        color: Color(0xFF4A3298),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '$title',
              style: TextStyle(
                color: Colors.white,
                fontSize: getProportionateScreenWidth(12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // SizedBox(height: getProportionateScreenWidth(10)),
          Center(
            child: Text(
              '$value',// Display the total value here
              style: TextStyle(
                color: Colors.white,
                fontSize: getProportionateScreenWidth(24),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}