import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/models/Cart.dart';
import 'package:shop_app/screens/cart/components/scanner.dart';
import 'package:shop_app/screens/login_success/login_success_screen.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../home/components/icon_btn_with_counter.dart';
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

  void onPressCheckout() async {
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
      final CollectionReference cartCollection =
      firestore.collection('transactions_${user.uid}');
      final List<Map<String, dynamic>> cartItems = demoCartsMap.values.map((cart) => cart.toMap()).toList();
      // Create a new document with an auto-generated ID and a timestamp
      final DocumentReference cartDocument = await cartCollection.add({
        'items': cartItems, // Assuming demoCartsMap is a Map of cart items
        'total': cartTotal, // Implement a function to calculate the total
        'timestamp': FieldValue.serverTimestamp(), // Add the timestamp field
      });

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

  // Future<void> scanBarcode(BuildContext context) async {
  //   // var res = await FlutterBarcodeScanner.scanBarcode(
  //   //     "#ff6666",
  //   //     "Cancel",
  //   //     true,
  //   //     ScanMode.BARCODE);
  //   FlutterBarcodeScanner.getBarcodeStreamReceiver("#ff6666", "Cancel", true, ScanMode.BARCODE)
  //       ?.listen((barcode) async {
  //     final player = AudioPlayer();
  //     print(barcode);
  //     if(barcode!="-1") {
  //       if (barcode == "8901088080262") {
  //         setState(() {
  //           demoCarts[0].numOfItem++;
  //         });
  //       }
  //       else {
  //         setState(() {
  //           demoCarts[1].numOfItem++;
  //         });
  //       }
  //       updateTotal();
  //       await player.play(AssetSource('sound/beep.mp3'));
  //     }
  //   });
  //
  //     // if (res is String && res!="-1") {
  //     // final player = AudioPlayer();
  //     // await player.play(AssetSource('sound/beep.mp3'));
  //     // var result = res;
  //     // print(res);
  //
  //   }


  @override
  Widget build(BuildContext context) {
    updateTotal();
    return Scaffold(
      appBar: buildAppBar(context),
      body: Body(updateTotal: updateTotal),
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
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 9, 0), // Adjust the margin as needed
          child: InkWell(
            onTap: () async => {
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
