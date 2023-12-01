import 'package:flutter/material.dart';
import 'package:shop_app/screens/history/components/transactions.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionData transaction;
  final Map<String, Map<String, dynamic>> productDetails;

  TransactionDetailsScreen({required this.transaction,required this.productDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDataRow('Total', '${transaction.total}'),
            buildDataRow('Payment Method', transaction.paymentMethod),
            buildDataRow('Items', ''),
            buildItemsTable(),
            // buildDataRow('Pincode', transaction.metadata['pincode']),
            buildDataRow('Payment Method', transaction.paymentMethod),
            buildDataRow('Timestamp', transaction.timestamp.toString()),
          ],
        ),
      ),
    );
  }

  Widget buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8.0),
          Text(value),
        ],
      ),
    );
  }

  Widget buildItemsTable() {
    return Table(
      border: TableBorder.all(), // Add a border around the entire table
      columnWidths: {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(3),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[300], // Add background color to the header row
          ),
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Product Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Quantity',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Selling Price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        ...transaction.items.map(
              (item) => TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    productDetails[item.productId]?['name'] ?? '',
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.numOfItem.toString(),
                  ),
                ),
              ),
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.sellingPrice.toString(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}