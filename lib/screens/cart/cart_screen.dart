import 'dart:ffi';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_app/models/Cart.dart';
import 'package:shop_app/screens/cart/components/scanner.dart';
import 'package:shop_app/screens/login_success/login_success_screen.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../home/components/icon_btn_with_counter.dart';
import 'components/barcodePopUp.dart';
import 'components/body.dart';
import 'components/check_out_card.dart';
import 'components/body.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CartScreen extends StatefulWidget {
  static String routeName = "/cart";

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateTotal();
  }
  double cartTotal=0;

  void onPressCheckout(String paymentMethod) async {
    // Ensure the user is signed in and has a UID
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null||cartTotal<=0) {
      // Handle the case where the user is not signed in
      // You may want to display an error message or navigate to a login screen
      return;
    }

    // Initialize Firestore
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Create a Firestore collection reference with the user's UID as a prefix
      // print('transactions/${user.uid}');
      DocumentSnapshot userSnapshot =
      await firestore.collection('users').doc(user.uid).get();
      String userPincode = userSnapshot['pincode'];
      final metadata = {
        'pincode': userPincode,
        // Add other metadata fields if needed
      };
      final CollectionReference cartCollection =
      firestore.collection('transactions_${user.uid}');
      final List<Map<String, dynamic>> cartItems = demoCartsMap.values.map((cart) => cart.toMap()).toList();
      // Create a new document with an auto-generated ID and a timestamp
      final DocumentReference cartDocument = await cartCollection.add({
        'items': cartItems, // Assuming demoCartsMap is a Map of cart items
        'total': cartTotal, // Implement a function to calculate the total
        'timestamp': FieldValue.serverTimestamp(), // Add the timestamp field
        'paymentMethod': paymentMethod,
        'metadata': metadata
      });
      final CollectionReference transactions =firestore.collection('transactions');
      final transactionDocumentReference=transactions.add({
        'userID': user.uid,
        'transactionID': cartDocument.id,
        'timestamp': FieldValue.serverTimestamp(),
      });
      final CollectionReference productPriceUpdate = firestore.collection('productPriceUpdate');
      print("here");
      for (var cartItem in cartItems) {
        final String productID = cartItem['productId'];
        final int sellingPrice = cartItem['sellingPrice'];
        print("inside for loop");

        // Query the product table to get MRP
        final DocumentSnapshot productSnapshot = await firestore.collection('products').doc(productID).get();

        // Check if the 'mrp' field exists and is not null in the document
        if (productSnapshot.exists && productSnapshot['mrp'] != null) {
          final String mrp = productSnapshot['mrp'];

          print("got mrp");
          // Check if the product ID is already present in productPriceUpdate
          final existingDocument = await productPriceUpdate.doc(productID).get();

          // Check if sellingPrice is greater than MRP before adding
          if (!existingDocument.exists && sellingPrice > int.parse(mrp)) {
            // Product ID not present, add it with a timestamp, MRP, and selling price
            await productPriceUpdate.doc(productID).set({
              'timestamp': FieldValue.serverTimestamp(),
              'mrp': mrp,
              'sellingPrice': sellingPrice,
              // Add other fields related to product price update if needed
            });
            print("product added to new database");
          }
        } else {
          // Handle the case where 'mrp' field is missing or null
          print("Warning: 'mrp' field is missing or null for product ID: $productID");
        }
      }

      // Cart data has been successfully saved to Firestore, clear the demo cart
      setState(() {
        demoCartsMap.clear();
        updateTotal();
      });

      // Navigate to the next screen (LoginSuccessScreen) or perform any other actions
      Navigator.pushReplacementNamed(context, LoginSuccessScreen.routeName);
    } catch (error) {
      // Cart data could not be saved to Firestore, handle the error as needed
      print('Error saving cart to Firestore: $error');
      // You can display an error message or retry, depending on your use case
    }
  }
  void updateTotal() {
    // Calculate the total here
    double total = 0.0;


    for (final cart in demoCartsMap.values) {
      total += cart.item.price * cart.numOfItem;
    }

    // Update the cartTotal and rebuild the widget
    setState(() {
      cartTotal = total;
    });
  }


  Future<void> showProductDetailsPopup(
      Map<String, dynamic> productData,
      String barcode,
      String productId,
      ) async {
    TextEditingController sellingPriceController =
    TextEditingController(text: productData["mrp"].toString());
    TextEditingController quantityController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              productData["name"],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    Center(
                      child: Image.network(
                        productData["image"],
                        height: 100.0,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: Text(
                        "MRP: ${productData["mrp"]}",
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: sellingPriceController,
                      decoration: InputDecoration(
                        labelText: 'Enter Selling Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Selling Price is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Enter Quantity Sold',
                    border: OutlineInputBorder(),
                    hintText: '1',
                  ),
                  keyboardType: TextInputType.number,
                  // initialValue: '1', // Set the default value here
                  onSaved: (value) {
                    // If the user didn't enter anything, set the default value as '1'
                    // quantityController.text = value?.isEmpty ?? true ? '1' : value!;
                  },
                ),

                ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  int sellingPrice =
                      int.tryParse(sellingPriceController.text) ?? 0;
                  int quantity = int.tryParse(quantityController.text) ?? 1;

                  if (sellingPrice > 0 && quantity > 0) {
                    final newCartItem = CartItem(
                      name: productData["name"],
                      mrp: int.parse(productData["mrp"].toString()),
                      barcode: barcode,
                      categoryId: productData["categoryId"],
                      productId: productId,
                      price: sellingPrice,
                      image: productData["image"],
                    );

                    setState(() {
                      demoCartsMap[barcode] =
                          Cart(item: newCartItem, numOfItem: quantity);
                      updateTotal();
                    });

                    Navigator.of(context).pop(); // Close the pop-up
                  }
                }
              },
              child: Text(
                'Add to Cart',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BarcodePopupForm(
                      scannedBarcode: productData['barcode'],
                      isPresent: 1,
                    );
                  },
                );
                Navigator.of(context).pop();
              },
              child: Text(
                'Update',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    updateTotal();
    return Scaffold(
      appBar: buildAppBar(context),
      body: Body(updateTotal: updateTotal,showProductDetailsPopup: showProductDetailsPopup),
      bottomNavigationBar: CheckoutCard(cartTotal: cartTotal,onPressCheckout: onPressCheckout,),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        children: [
          Text(
            "Your Cart",
            style: TextStyle(color: Colors.black),
          ),
          Text(
            "${demoCartsMap.length} items",
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 18, 9, 0),
          child: GestureDetector(
            onTap: () async => {
              // scanBarcodes()
              Navigator.pushNamed(context, BarcodeListScannerWithController.routeName).then((_) => setState(() {}))
            },
            child: RichText(
              text: TextSpan(
                text: "Scan More",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18, // Adjust the font size as needed
                ),
              ),
            ),
          ),
        ),

        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 9, 0), // Adjust the margin as needed
          child: InkWell(
            onTap: () async => {
              // scanBarcodes()
              Navigator.pushNamed(context, BarcodeListScannerWithController.routeName).then((_) => setState(() {}))
            },
            child: Transform.scale(
              scale: 1.5, // Adjust the scale factor as needed
              child: Icon(
                Icons.qr_code, // You can use the appropriate IconData for QR code
                color: Colors.black, // Customize the color
              ),
            ),
          ),
        )
      ],
    );
  }
}
