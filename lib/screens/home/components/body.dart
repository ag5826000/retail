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
  Map<String, Map<String, dynamic>> productDetails = {};

  @override
  void initState() {
    super.initState();
    _getTransactionsTotal(widget.rangeStart, widget.rangeEnd);
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
    final CollectionReference transactionsCollection =
    firestore.collection('transactions_$userId');

    try {
      QuerySnapshot querySnapshot = await transactionsCollection
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .where('timestamp', isLessThanOrEqualTo: end)
          .get();

      double total = 0;
      int calculatedTotalItems = 0;

      Map<String, ProductData> productMap = {};

      // Gather unique product IDs from all transactions
      Set<String> uniqueProductIds = {};
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        List<dynamic> items = document['items'];
        for (var item in items) {
          uniqueProductIds.add(item['productId']);
        }
      }

      // Fetch product details for the unique product IDs
      final List<DocumentSnapshot> productDocs = await Future.wait(
        uniqueProductIds.map((productId) =>
            firestore.collection('products').doc(productId).get()),
      );

      // Create a map of product details based on product ID

      for (var productDoc in productDocs) {
        productDetails[productDoc.id] = productDoc.data() as Map<String, dynamic>;
      }
      // print(productDetails.toString());
      // Process each transaction
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        List<dynamic> items = document['items'];
        for (var item in items) {
          String productId = item['productId'];
          Map<String, dynamic> productData = productDetails[productId] ?? {};

          String productName = productData['name'] ?? 'Unknown Product';
          int currentItems = item['numOfItem'] as int;
          int productPrice = (item['sellingPrice'] as int) * currentItems;
          calculatedTotalItems += currentItems;

          if (productMap.containsKey(productId)) {
            productMap[productId] = ProductData(
              productName,
              productMap[productId]!.revenue + productPrice,
              productMap[productId]!.count + currentItems,
            );
          } else {
            productMap[productId] =
                ProductData(productName, productPrice, currentItems);
          }
        }

        total += document['total'];
      }

      totalTransactions = querySnapshot.size;
      double calculatedAverage = total / querySnapshot.size;
      products = productMap.values.toList();

      setState(() {
        totalValue = total;
        totalItems = calculatedTotalItems;
        averageTransactionValue = calculatedAverage;
        products = productMap.values.toList();
      });
    } catch (e) {
      print('Error retrieving transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFFFF), // Set the background color here
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeHeader(rangeStart: widget.rangeStart, rangeEnd: widget.rangeEnd),
              SizedBox(height: getProportionateScreenWidth(10)),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(1)),
                    child: DiscountBanner(
                      values: [
                        '₹' + totalValue.toString(),
                        totalItems.toString(),
                        totalTransactions.toString(),
                      ],
                      titles: [
                        "Revenue",
                        "Items Sold",
                        "Transactions",
                      ],
                    ),
                  ),
                  // Add other widgets in the Row as needed
                ],
              ),




              // children: [
                //   Expanded(
                //     child: DiscountBanner(
                //       value: totalTransactions.toString(),
                //       title: "Total Transactions",
                //     ),
                //   ),
                //   // Expanded(
                //   //   child: DiscountBanner(
                //   //     value: averageTransactionValue.toString(),
                //   //     title: "Avg Transaction Value",
                //   //   ),
                //   // ),
                // ],

              SizedBox(height: getProportionateScreenWidth(15)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Set the background color here
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2), // Adjust the offset as needed
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              child: Column(
                children: [
                  SectionTitle(
                    title: "Top Revenue Products",
                    cta: "See All",
                    press: () {
                      Navigator.pushNamed(
                        context,
                        AllProductsTable.routeName,
                        arguments: {
                          'rangeStart': widget.rangeStart,
                          'rangeEnd': widget.rangeEnd,
                          'numberOfProducts': -1,
                          'groupBy': "name",
                          'appbarText': 'All Products Table',
                          'productDetails': productDetails
                        },
                      );
                    },
                  ),
                  SizedBox(height: getProportionateScreenWidth(10)),
                  ProductDataTable(
                    rangeStart: widget.rangeStart,
                    rangeEnd: widget.rangeEnd,
                    numberOfProducts: 5,
                    groupBy: "name",
                  ),
                ],
              ),
            ),
          ),


          SizedBox(height: getProportionateScreenWidth(15)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Set the background color here
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 2), // Adjust the offset as needed
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  child: Column(
                    children: [
                      SectionTitle(
                        title: "Category Wise Performance",
                        cta: "See All",
                        press: () {
                          Navigator.pushNamed(
                            context,
                            AllProductsTable.routeName,
                            arguments: {
                              'rangeStart': widget.rangeStart,
                              'rangeEnd': widget.rangeEnd,
                              'numberOfProducts': -1,
                              'groupBy': "categoryId",
                              'appbarText': 'All Categories Table',
                              'productDetails': productDetails
                            },
                          );
                        },
                      ),
                      SizedBox(height: getProportionateScreenWidth(10)),
                      ProductDataTable(
                        rangeStart: widget.rangeStart,
                        rangeEnd: widget.rangeEnd,
                        numberOfProducts: 5,
                        groupBy: "categoryId",
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: getProportionateScreenWidth(30)),
            ],
          ),
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
