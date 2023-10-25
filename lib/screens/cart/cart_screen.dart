import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/models/Cart.dart';
import 'package:shop_app/screens/cart/components/scanner.dart';
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
  void updateTotal() {
    // Calculate the total here
    double total = 0.0;
    for (final cart in demoCarts) {
      total += cart.product.price * cart.numOfItem;
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
      bottomNavigationBar: CheckoutCard(cartTotal: cartTotal),
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
            "${demoCarts.length} items",
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
