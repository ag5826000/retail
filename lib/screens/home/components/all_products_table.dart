import 'package:flutter/material.dart';
import 'package:shop_app/screens/home/components/products_table.dart';

class AllProductsTable extends StatefulWidget {
  const AllProductsTable({Key? key}) : super(key: key);
  static String routeName = "/allProductsTable";

  @override
  _AllProductsTableState createState() => _AllProductsTableState();
}

class _AllProductsTableState extends State<AllProductsTable> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    DateTime? rangeStart = args?['rangeStart'];
    DateTime? rangeEnd = args?['rangeEnd'];
    int? numberOfProducts=args?['numberOfProducts'];
    String? groupBy=args?['groupBy'];
    String? appbarText=args?['appbarText'];
    return Scaffold(
      appBar: AppBar(
        title: Text('$appbarText'),
      ),
      body: ProductDataTable(
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        numberOfProducts: numberOfProducts!,
        groupBy: groupBy!,
      ),
    );
  }
}