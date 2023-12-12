import 'dart:async';
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
  late Timer movingLineTimer;
  late double linePosition ;
  double lineSpeed = 2.0; // Adjust as needed
  late double lineLower;
  late double lineUpper;
  double scanWindowWidthPercentage = 80.0; // Adjust as needed
  double scanWindowHeightPercentage = 20.0; // Adjust as needed
  List<String> scannedBarcodes = [];

  @override
  void initState() {
    super.initState();

    // Initialize a timer to move the line up and down
    movingLineTimer = Timer.periodic(Duration(milliseconds: 18), (Timer timer) {
      setState(() {
        linePosition += lineSpeed;
        if (linePosition > lineLower) {
          lineSpeed = lineSpeed*-1;
        }
        else if(linePosition <lineUpper)
          {
            lineSpeed = lineSpeed*-1;
          }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    linePosition = MediaQuery.of(context).size.height / 2;
    lineLower = linePosition + MediaQuery.of(context).size.height * (scanWindowHeightPercentage / 100) / 2;
    lineUpper = linePosition - MediaQuery.of(context).size.height * (scanWindowHeightPercentage / 100) / 2;
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    movingLineTimer.cancel();
    super.dispose();
  }

  MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    // formats: [BarcodeFormat.qrCode]
    // facing: CameraFacing.front,
    detectionSpeed: DetectionSpeed.unrestricted,
    detectionTimeoutMs: 1,
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
                        hintText: 'Enter Quantity Sold',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Quantity is required';
                        }
                        return null;
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
                  int quantity = int.tryParse(quantityController.text) ?? 0;

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

  Future<void> processBarcode(String barCode) async {
    if (barCode != '-1') {
      final player = AudioPlayer();
      var db = FirebaseFirestore.instance;
      CollectionReference productsCollection =db.collection('products');
      QuerySnapshot querySnapshot = await productsCollection.where('barcode', isEqualTo: barCode).get();
      if (querySnapshot.docs.isNotEmpty) {
        player.play(AssetSource('sound/beep.mp3'));
        Map<String, dynamic> jsonData = querySnapshot.docs[0].data() as Map<String, dynamic>;
        String productId = querySnapshot.docs[0].id;
        await showProductDetailsPopup(jsonData, barCode,productId);
        _startOrStop();
      }
      else {
        setState(() async {
          await player.play(AssetSource('sound/beep.mp3'));

          final metadata = {
            'brand': "NA",
            // Add other metadata fields if needed
          };

          final product = <String, dynamic>{
            "name": barCode,
            "mrp": 0,
            "barcode": barCode,
            "lastUpdatedAt": FieldValue.serverTimestamp(),
            "categoryId": "fmcg_000",
            "metadata": metadata,
          };
          product["image"] = "https://firebasestorage.googleapis.com/v0/b/retail-773cc.appspot.com/o/product_images%2FImageNotFound.jpeg?alt=media&token=856abe68-93b5-49e9-91bc-006c8e6f399a";

          db.collection("products").add(product).then((DocumentReference doc) =>
              print('DocumentSnapshot added with ID: ${doc.id}'));

          final notFound = <String, dynamic>{
            "barcode": barCode,
          };
          db.collection("addInDB").add(notFound);

          // await showDialog(
          //   context: context,
          //   builder: (BuildContext context) {
          //     return BarcodePopupForm(scannedBarcode: barCode,isPresent: 0,);
          //   },
          // );

          querySnapshot = await productsCollection.where('barcode', isEqualTo: barCode).get();
          if (querySnapshot.docs.isNotEmpty) {
            Map<String, dynamic> jsonData = querySnapshot.docs[0].data() as Map<String, dynamic>;
            String productId = querySnapshot.docs[0].id;
            await showProductDetailsPopup(jsonData, barCode,productId);

          }
          _startOrStop();
        });
      }



    }
  }

  @override
  Widget build(BuildContext context) {



    double scanWindowWidth = MediaQuery.of(context).size.width * (scanWindowWidthPercentage / 100);
    double scanWindowHeight = MediaQuery.of(context).size.height * (scanWindowHeightPercentage / 100);


    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: scanWindowWidth,
      height: scanWindowHeight,
    );
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
                scanWindow: scanWindow,
                onDetect: (barcode) async {

                  String barCode=barcode.barcodes[0].displayValue.toString();
                  scannedBarcodes.add(barCode);
                  print("yo =>"+barCode);

                  // Process the barcodes after scanning a sufficient number
                  if (scannedBarcodes.length >= 11) {
                    // Find the barcode with maximum frequency
                    Map<String, int> barcodeCounts = {};

                    for (String barcode in scannedBarcodes) {
                      barcodeCounts[barcode] = (barcodeCounts[barcode] ?? 0) + 1;
                    }

                    // Find the barcode with maximum frequency
                    String mostFrequentBarcode = barcodeCounts.keys.reduce((a, b) =>
                    barcodeCounts[a]! > barcodeCounts[b]! ? a : b);
                    print("Yeahhhh"+barcodeCounts.toString());
                    print("amigo"+mostFrequentBarcode);
                    processBarcode(mostFrequentBarcode);
                    _startOrStop();
                    scannedBarcodes.clear();
                  }
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
                onScannerStarted: (_) {
                  controller.setZoomScale(0.25);
                },
              ),
              CustomPaint(
                painter: ScannerOverlay(scanWindow),
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
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: linePosition),
                  width: scanWindow.width,
                  height: 2.0, // Thickness of the moving line
                  color: Colors.red,
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

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}