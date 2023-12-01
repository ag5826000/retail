import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/screens/history/components/transactions.dart';
import 'package:shop_app/screens/home/components/products_table.dart';
import 'package:shop_app/screens/home/components/section_title.dart';

import '../../../size_config.dart';
import 'history_header.dart';

class Body extends StatefulWidget {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  Body({this.rangeStart, this.rangeEnd});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getProportionateScreenHeight(20)),
            HistoryHeader(rangeStart: widget.rangeStart, rangeEnd :widget.rangeEnd),
            SizedBox(height: getProportionateScreenWidth(10)),
            UserTransactions(
              userId: FirebaseAuth.instance.currentUser!.uid,
              rangeStart: widget.rangeStart!,
              rangeEnd: widget.rangeEnd!,
            ),
          ],
        ),
      ),
    );
  }
}
