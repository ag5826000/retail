import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BarcodePopupForm extends StatefulWidget {
  final String scannedBarcode;
  BarcodePopupForm({required this.scannedBarcode});
  @override
  _BarcodePopupFormState createState() => _BarcodePopupFormState();
}

class _BarcodePopupFormState extends State<BarcodePopupForm> {
  String name = '';
  String mrp = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Create a form key

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("This Product Doesn't Exist in the Database",textAlign: TextAlign.center,),
      content: Form( // Wrap your form fields with a Form widget
        key: _formKey, // Assign the form key
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Barcode: ${widget.scannedBarcode}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField( // Change TextField to TextFormField
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Product name is required'; // Validate product name
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                hintText: 'Enter product name',
              ),
            ),
            SizedBox(height: 10),
            TextFormField( //
              keyboardType: TextInputType.number,// Change TextField to TextFormField
              onChanged: (value) {
                setState(() {
                  mrp = value;
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'MRP is required'; // Validate MRP
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'MRP Rs',
                border: OutlineInputBorder(),
                hintText: 'Enter MRP',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Add"),
          onPressed: () async {
            if (_formKey.currentState!.validate()) { // Validate the form
              final product = <String, dynamic>{
                "name": name,
                "mrp": mrp,
                "barcode": widget.scannedBarcode,
                "timestamp": FieldValue.serverTimestamp(),
              };
              var db = FirebaseFirestore.instance;
              db.collection("products").add(product).then((DocumentReference doc) =>
                  print('DocumentSnapshot added with ID: ${doc.id}'));
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
