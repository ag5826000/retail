import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../size_config.dart';

class DiscountBanner extends StatefulWidget {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  const DiscountBanner({Key? key, this.rangeStart, this.rangeEnd}) : super(key: key);

  @override
  State<DiscountBanner> createState() => _DiscountBannerState();
}

class _DiscountBannerState extends State<DiscountBanner> {
  double totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    _getTransactionsTotal(widget.rangeStart,widget.rangeEnd);
  }

  Future<void> _getTransactionsTotal(DateTime? start, DateTime? end) async {
    if (start == null || end == null) {
      return; // Return early if start or end date is not provided
    }

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      // Handle the case where the user is not authenticated
      return;
    }

    final String userId = user.uid; // Get the user's UID

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference transactionsCollection = firestore.collection('transactions_$userId');

    try {
      QuerySnapshot querySnapshot = await transactionsCollection
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .where('timestamp', isLessThanOrEqualTo: end)
          .get();

      double total = 0;

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> jsonData = document.data() as Map<String, dynamic>;
        double transactionTotal = jsonData['total'];
        total += transactionTotal;
      }
      print(total);

      setState(() {
        totalValue = total;
      });
    } catch (e) {
      print('Error retrieving transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 90,
      width: double.infinity,
      margin: EdgeInsets.all(getProportionateScreenWidth(20)),
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(20),
        vertical: getProportionateScreenWidth(15),
      ),
      decoration: BoxDecoration(
        color: Color(0xFF4A3298),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text.rich(
        TextSpan(
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(text: "Total Value\n"),
            TextSpan(
              text: '₹$totalValue', // Display the total value here
              style: TextStyle(
                fontSize: getProportionateScreenWidth(24),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}