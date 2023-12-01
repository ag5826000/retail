import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/screens/history/components/transaction_details_popup.dart';

class UserTransactions extends StatefulWidget {
  final String userId;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  UserTransactions({
    required this.userId,
    required this.rangeStart,
    required this.rangeEnd,
  });

  @override
  State<UserTransactions> createState() => _UserTransactionsState();
}

class _UserTransactionsState extends State<UserTransactions> {
  List<TransactionData>? transactions;
  Map<String, Map<String, dynamic>> productDetails = {};

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('transactions_${widget.userId}')
          .where('timestamp', isGreaterThanOrEqualTo: widget.rangeStart)
          .where('timestamp', isLessThanOrEqualTo: widget.rangeEnd)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Set<String> uniqueProductIds = {};
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          List<dynamic> items = document['items'];
          for (var item in items) {
            uniqueProductIds.add(item['productId']);
          }
        }
        final List<DocumentSnapshot> productDocs = await Future.wait(
          uniqueProductIds.map((productId) =>
              FirebaseFirestore.instance.collection('products').doc(productId).get()),
        );

        // Create a map of product details based on product ID

        for (var productDoc in productDocs) {
          productDetails[productDoc.id] = productDoc.data() as Map<String, dynamic>;
        }
        print(productDetails.toString());
        setState(() {
          transactions = querySnapshot.docs
              .map((DocumentSnapshot document) =>
              TransactionData.fromMap(document.data() as Map<String, dynamic>))
              .toList();
        });
      } else {
        setState(() {
          transactions = [];
        });
      }
    } catch (error) {
      // Handle the error as needed
      print('Error fetching transactions: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (transactions == null) {
      // Loading indicator
      return CircularProgressIndicator();
    }

    if (transactions!.isEmpty) {
      return Text('No transactions found.');
    }

    // Display the transactions
    return Column(
      children: transactions!.map((TransactionData transaction) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailsScreen(
                  transaction: transaction,
                  productDetails: productDetails,
                ),
              ),
            );
          },
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            child: ListTile(
              title: Text('Total: ${transaction.total}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Method: ${transaction.paymentMethod}'),
                  Text('Timestamp: ${transaction.timestamp.toLocal()}'),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class TransactionData {
  final double total;
  final String paymentMethod;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final List<TransactionItem> items;

  TransactionData({
    required this.total,
    required this.paymentMethod,
    required this.timestamp,
    required this.metadata,
    required this.items,
  });

  factory TransactionData.fromMap(Map<String, dynamic> map) {
    return TransactionData(
      total: (map['total'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(map['metadata']),
      items: List<TransactionItem>.from(
        (map['items'] as List).map((item) => TransactionItem.fromMap(item)),
      ),
    );
  }
}

class TransactionItem {
  final int numOfItem;
  final String productId;
  final double sellingPrice;

  TransactionItem({
    required this.numOfItem,
    required this.productId,
    required this.sellingPrice,
  });

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      numOfItem: map['numOfItem'] ?? 0,
      productId: map['productId'] ?? '',
      sellingPrice: (map['sellingPrice'] ?? 0.0).toDouble(),
    );
  }
}