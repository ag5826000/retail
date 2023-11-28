

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/screens/home/components/products_table.dart';
import 'package:shop_app/screens/home/components/section_title.dart';

import '../../../size_config.dart';
import 'all_products_table.dart';
import 'categories.dart';
import 'discount_banner.dart';
import 'home_header.dart';
import 'popular_product.dart';
import 'special_offers.dart';

class Body extends StatefulWidget {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  Body({this.rangeStart, this.rangeEnd});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  double totalValue = 0.0;
  int totalItems = 0;
  double averageTransactionValue = 0;
  int totalTransactions =0;
  Map<String, ProductData> productList = {};
  List<ProductData> products=[];

  @override
  void initState() {
    super.initState();
    _getTransactionsTotal(widget.rangeStart, widget.rangeEnd);
    print("_getTransactionsTotal called");
  }

  Future<void> _getTransactionsTotal(DateTime? start, DateTime? end) async {
    if (start == null || end == null) {
      return;
    }

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      return;
    }

    final String userId = user.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference transactionsCollection = firestore.collection('transactions_$userId');

    try {
      QuerySnapshot querySnapshot = await transactionsCollection
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .where('timestamp', isLessThanOrEqualTo: end)
          .get();

      double total = 0;
      int calculatedTotalItems = 0;

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> jsonData = document.data() as Map<String, dynamic>;
        double transactionTotal = jsonData['total'];

        List<dynamic> items = jsonData['items'];
        print(items.toString());
        for (var item in items) {

          String productId = item['productId'];
          print('productId : $productId');
          // String productName = item['title'];
          int currentItems=item['numOfItem'] as int;

          DocumentSnapshot productDoc =
          await firestore.collection('products').doc(productId).get();
          if (productDoc.exists) {
            Map<String, dynamic> productData = productDoc.data() as Map<String,dynamic>;

            String productName = productData['name'];
            print('productName : $productName');
            int productPrice = (int.parse(productData['mrp'])) * currentItems;
            print('productPrice : $productPrice');
            // int productPrice = (item['price'] as int) * (currentItems);
            calculatedTotalItems += currentItems;
            if (productList.containsKey(productName)) {
              productList[productName] = ProductData(
                productName,
                productList[productName]!.revenue + productPrice,
                productList[productName]!.count + currentItems,
              );
            } else {
              productList[productName] =
                  ProductData(productName, productPrice, currentItems);
            }
          }
          // productRevenue.update(productName, (value) => value + productPrice, ifAbsent: () => productPrice);
          // productCount.update(productName, (value) => value + calculatedTotalItems, ifAbsent: () => calculatedTotalItems);
        }

        total += transactionTotal;
      }
      totalTransactions=querySnapshot.size;
      double calculatedAverage = total / querySnapshot.size;
      String formattedAverage = calculatedAverage.toStringAsFixed(2);

      products=productList.values.toList();
      //print(productList.values.toList().length);
      setState(() {
        totalValue = total;
        totalItems = calculatedTotalItems;
        print('totalItems : $totalItems');
        averageTransactionValue = double.parse(formattedAverage);
        print('averageTransactionValue : $averageTransactionValue');
        products= productList.values.toList();
        print(products.length);
      });
    } catch (e) {
      print('Error retrieving transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getProportionateScreenHeight(20)),
            HomeHeader(rangeStart: widget.rangeStart, rangeEnd :widget.rangeEnd),
            SizedBox(height: getProportionateScreenWidth(10)),
            Row(
              children: [
                Expanded(
                  child: DiscountBanner(
                    value: '₹'+totalValue.toString() ,
                    title: "Total Revenue",
                  ),
                ),
                Expanded(
                  child: DiscountBanner(
                    value: totalItems.toString(),
                    title: "Total Items Sold",
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DiscountBanner(
                    value: totalTransactions.toString() ,
                    title: "Total Transactions",
                  ),
                ),
                Expanded(
                  child: DiscountBanner(
                    value: averageTransactionValue.toString(),
                    title: "Avg Transaction Value",
                  ),
                ),
              ],
            ),
            SizedBox(height: getProportionateScreenWidth(15)),
            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
              child: SectionTitle(
                title: "Top Revenue Products",
                cta: "See All Products",
                press: () {
                  Navigator.pushNamed(context, AllProductsTable.routeName,   arguments: {'rangeStart': widget.rangeStart, 'rangeEnd':  widget.rangeEnd,'numberOfProducts':-1,'groupBy': "title",'appbarText': 'All Products Table'});
                },
              ),
            ),
            SizedBox(height: getProportionateScreenWidth(10)),
            ProductDataTable(rangeStart: widget.rangeStart, rangeEnd :widget.rangeEnd, numberOfProducts: 5, groupBy: "title"),
            SizedBox(height: getProportionateScreenWidth(15)),
            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
              child: SectionTitle(
                title: "Category Wise Performance",
                cta: "See All",
                press: () {
                  Navigator.pushNamed(context, AllProductsTable.routeName,   arguments: {'rangeStart': widget.rangeStart, 'rangeEnd':  widget.rangeEnd,'numberOfProducts':-1,'groupBy': "category",'appbarText': 'All Categories Table'});
                },
              ),
            ),
            SizedBox(height: getProportionateScreenWidth(10)),
            ProductDataTable(rangeStart: widget.rangeStart, rangeEnd :widget.rangeEnd, numberOfProducts: 5,  groupBy: "category"),
            // Categories(),
            // SpecialOffers(),
            // SizedBox(height: getProportionateScreenWidth(30)),
            // PopularProducts(),
            SizedBox(height: getProportionateScreenWidth(30)),
          ],
        ),
      ),
    );
  }
}

class ProductData  {
  final String name;
  final int revenue;
  final int count;

  ProductData(this.name, this.revenue, this.count);
}
