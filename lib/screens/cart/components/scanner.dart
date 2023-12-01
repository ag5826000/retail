import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shop_app/screens/cart/components/scanner_error_widget.dart';

import '../../../models/Cart.dart';
import 'barcodePopUp.dart';

class BarcodeListScannerWithController extends StatefulWidget {
  const BarcodeListScannerWithController({super.key});
  static String routeName = "/scanner";

  @override
  State<BarcodeListScannerWithController> createState() =>
      _BarcodeListScannerWithControllerState();
}

class _BarcodeListScannerWithControllerState
    extends State<BarcodeListScannerWithController>
    with SingleTickerProviderStateMixin{

  BarcodeCapture? barcode;
  bool showAnimatedIcon  = false;

  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    // formats: [BarcodeFormat.qrCode]
    // facing: CameraFacing.front,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 1500,
    // returnImage: false,
  );

  bool isStarted = true;

  void _startOrStop() {
    try {
      if (isStarted) {
        controller.stop();
      } else {
        controller.start();
      }
      setState(() {
        isStarted = !isStarted;
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong! $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              MobileScanner(
                controller: controller,
                errorBuilder: (context, error, child) {
                  return ScannerErrorWidget(error: error);
                },
                fit: BoxFit.contain,
                onDetect: (barcode) {
                  // setState(() async {
                  //   final player = AudioPlayer();
                  //   print(barcode.barcodes[0].displayValue);
                  //   String barCode=barcode.barcodes[0].displayValue.toString();
                  //   var db = FirebaseFirestore.instance;
                  //   CollectionReference productsCollection =db.collection('products');
                  //   QuerySnapshot querySnapshot = await productsCollection.where('barcode', isEqualTo: barCode).get();
                  //
                  //
                  //   if (querySnapshot.docs.isNotEmpty) {
                  //     Map<String, dynamic> jsonData = querySnapshot.docs[0].data() as Map<String, dynamic>;
                  //     setState(() async {
                  //       if (demoCartsMap.containsKey(barCode)) {
                  //         demoCartsMap[barCode]!.numOfItem++;
                  //         setState(() {
                  //           showAnimatedIcon  = true;
                  //         });
                  //         Future.delayed(Duration(seconds: 1), () {
                  //           setState(() {
                  //             showAnimatedIcon = false;
                  //           });
                  //         });
                  //         await player.play(AssetSource('sound/beep.mp3'));
                  //       } else {
                  //         final newCartItem = CartItem(
                  //           title: jsonData["name"], // Replace with the actual field name
                  //           price: int.parse(jsonData["mrp"]), // Replace with the actual field name
                  //           barcode: barCode,
                  //           category: jsonData["category"]
                  //         );
                  //
                  //         demoCartsMap[barCode] = Cart(item: newCartItem, numOfItem: 1);
                  //         setState(() {
                  //           showAnimatedIcon  = true;
                  //         });
                  //         Future.delayed(Duration(seconds: 1), () {
                  //           setState(() {
                  //             showAnimatedIcon = false;
                  //           });
                  //         });
                  //         await player.play(AssetSource('sound/beep.mp3'));
                  //       }
                  //     });
                  //   }
                  //   else {
                  //     setState(() async {
                  //       await player.play(AssetSource('sound/beep.mp3'));
                  //       _startOrStop();
                  //       // await showDialog(
                  //       //   context: context,
                  //       //   builder: (BuildContext context) {
                  //       //     return BarcodePopupForm(scannedBarcode: barCode);
                  //       //   },
                  //       // );
                  //       querySnapshot = await productsCollection.where('barcode', isEqualTo: barCode).get();
                  //       if (querySnapshot.docs.isNotEmpty) {
                  //         Map<String, dynamic> jsonData = querySnapshot.docs[0]
                  //             .data() as Map<String, dynamic>;
                  //         final newCartItem = CartItem(
                  //           title: jsonData["name"],
                  //           // Replace with the actual field name
                  //           price: int.parse(jsonData["mrp"]),
                  //           // Replace with the actual field name
                  //           barcode: barCode,
                  //           category: jsonData["category"]
                  //         );
                  //
                  //         demoCartsMap[barCode] =
                  //             Cart(item: newCartItem, numOfItem: 1);
                  //         setState(() {
                  //           showAnimatedIcon  = true;
                  //         });
                  //         Future.delayed(Duration(seconds: 1), () {
                  //           setState(() {
                  //             showAnimatedIcon = false;
                  //           });
                  //         });
                  //       };
                  //       _startOrStop();
                  //     });
                  //   }
                  //
                  //
                  //   this.barcode = barcode;
                  //
                  // });
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Visibility(
                  visible: showAnimatedIcon,
                  child: AnimatedOpacity(
                    opacity: showAnimatedIcon ? 1.0 : 0.0,
                    duration: Duration(seconds: 1),
                    child: Animate(
                      effects: [ShakeEffect(duration: 500.ms), ScaleEffect(duration: 300.ms)],
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        height: 100,
                        color: Colors.black.withOpacity(0.4),
                        child: Center(
                          child: Icon(
                            Icons.check_circle, // You can choose any desired icon
                            color: Colors.green,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 100,
                  color: Colors.black.withOpacity(0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: controller.hasTorchState,
                        builder: (context, state, child) {
                          if (state != true) {
                            return const SizedBox.shrink();
                          }
                          return IconButton(
                            color: Colors.white,
                            icon: ValueListenableBuilder<TorchState>(
                              valueListenable: controller.torchState,
                              builder: (context, state, child) {
                                switch (state) {
                                  case TorchState.off:
                                    return const Icon(
                                      Icons.flash_off,
                                      color: Colors.grey,
                                    );
                                  case TorchState.on:
                                    return const Icon(
                                      Icons.flash_on,
                                      color: Colors.yellow,
                                    );
                                }
                              },
                            ),
                            iconSize: 32.0,
                            onPressed: () => controller.toggleTorch(),
                          );
                        },
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: isStarted
                            ? const Icon(Icons.stop)
                            : const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                        onPressed: _startOrStop,
                      ),
                      // Center(
                      //   child: SizedBox(
                      //     width: MediaQuery.of(context).size.width - 200,
                      //     height: 50,
                      //     child: FittedBox(
                      //       child: Text(
                      //         barcode?.barcodes.first.rawValue ??
                      //             'Scan something!',
                      //         overflow: TextOverflow.fade,
                      //         style: Theme.of(context)
                      //             .textTheme
                      //             .headlineMedium!
                      //             .copyWith(color: Colors.white),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      IconButton(
                        color: Colors.white,
                        icon: ValueListenableBuilder<CameraFacing>(
                          valueListenable: controller.cameraFacingState,
                          builder: (context, state, child) {
                            switch (state) {
                              case CameraFacing.front:
                                return const Icon(Icons.camera_front);
                              case CameraFacing.back:
                                return const Icon(Icons.camera_rear);
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => controller.switchCamera(),
                      ),
                      // IconButton(
                      //   color: Colors.white,
                      //   icon: const Icon(Icons.image),
                      //   iconSize: 32.0,
                      //   onPressed: () async {
                      //     final ImagePicker picker = ImagePicker();
                      //     // Pick an image
                      //     final XFile? image = await picker.pickImage(
                      //       source: ImageSource.gallery,
                      //     );
                      //     if (image != null) {
                      //       if (await controller.analyzeImage(image.path)) {
                      //         if (!mounted) return;
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           const SnackBar(
                      //             content: Text('Barcode found!'),
                      //             backgroundColor: Colors.green,
                      //           ),
                      //         );
                      //       } else {
                      //         if (!mounted) return;
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           const SnackBar(
                      //             content: Text('No barcode found!'),
                      //             backgroundColor: Colors.red,
                      //           ),
                      //         );
                      //       }
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}