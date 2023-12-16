import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class BarcodePopupForm extends StatefulWidget {
  final String scannedBarcode;
  final int isPresent;
  BarcodePopupForm({required this.scannedBarcode,required this.isPresent});
  @override
  _BarcodePopupFormState createState() => _BarcodePopupFormState();
}

class _BarcodePopupFormState extends State<BarcodePopupForm> {
  String name = '';
  String mrp = '';
  String? selectedCategory;
  File? selectedImage;
  String selectedCategoryId = '';
  String? fileName;
  String brand = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isPresent == 1
            ? "Update Product Details"
            : "This Product Doesn't Exist in the Database",
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Barcode: ${widget.scannedBarcode}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
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
              TextFormField(
                keyboardType: TextInputType.number,
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
              SizedBox(height: 10),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    brand = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Brand is required'; // Validate MRP
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Brand Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter Brand Name',
                ),
              ),
              SizedBox(height: 10),
              IntrinsicWidth(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    hintText: 'select category',
                  ),
                  value: selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (selectedCategory == null) {
                      return 'Please Select Product Category';
                    }
                    return null;
                  },
                  items: <String>[
                    'Food and Snacks',
                    'Household and Cleaning',
                    'Personal Care and Hygiene',
                    'Health and Wellness',
                    'Baby and Child Care',
                    'Frozen Foods',
                    'Dairy and Eggs',
                    'Baked Goods',
                    'Beverages',
                    'Pet Care',
                    'Staples'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(selectedImage != null
                        ? 'Image Uploaded'
                        : 'Select Image'),
                  ),
                  SizedBox(width: 10),
                  Visibility(
                    visible: fileName != null,
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Reupload'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // TextButton(
        //   child: Text("Scan Again"),
        //   onPressed: () {
        //     widget.onScanAgain();
        //     Navigator.of(context).pop();
        //   },
        // ),
        TextButton(
          child: Text(widget.isPresent == 1 ? "Update" : "Add to Database"),
          onPressed: _handleAddButtonPressed,
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    // Show a dialog to let the user choose the image source
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _getImage(ImageSource.camera);
                },
                child: Text('Camera'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _getImage(ImageSource.gallery);
                },
                child: Text('Gallery'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(
      source: source,
        maxHeight: 480,
        maxWidth: 640,
        imageQuality: 50// Adjust the quality as needed
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        print('Selected Image Extension: ${selectedImage!.path.split('.').last}');
        fileName = pickedFile.name; // Save the file name
      });
    } else {
      // Handle the case when the user didn't choose any file
      print('User canceled file picking or did not select a file.');
    }
  }

  // Future<void> _reuploadImage() async {
  //   final picker = ImagePicker();
  //   XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
  //
  //   if (pickedFile != null) {
  //     setState(() {
  //       selectedImage = File(imageUrl);
  //       fileName = pickedFile.name;
  //     });
  //   }
  // }

  Future<void> _handleAddButtonPressed() async {
    if (_formKey.currentState!.validate()) {
      if (selectedImage == null) {
        // Show an error message or dialog indicating that the user must select an image.
        // For example:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Image Required'),
              content: Text('Please select an image for the product.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return; // Do not proceed without an image.
      }

      String categoryId = await _getCategoryId(selectedCategory!);

      setState(() {
        selectedCategoryId = categoryId;
      });

      final metadata = {
        'brand': brand,
        // Add other metadata fields if needed
      };

      final product = <String, dynamic>{
        "name": name,
        "mrp": mrp,
        "barcode": widget.scannedBarcode,
        "lastUpdatedAt": FieldValue.serverTimestamp(),
        "categoryId": selectedCategoryId,
        "metadata": metadata,
      };

      String imageUrl = await _uploadImageToFirebaseStorage(selectedImage!);
      product["image"] = imageUrl;

      var db = FirebaseFirestore.instance;

      if (widget.isPresent == 1) {
        // Updating existing product
        // Check if a document with the same barcode already exists
        QuerySnapshot existingProduct = await db.collection("products")
            .where('barcode', isEqualTo: widget.scannedBarcode)
            .limit(1)
            .get();

        if (existingProduct.docs.isNotEmpty) {
          // Delete the current image from Firebase Storage
          String currentImageUrl = existingProduct.docs.first['image'];
          if (currentImageUrl.isNotEmpty) {
            if(currentImageUrl != "https://firebasestorage.googleapis.com/v0/b/retail-773cc.appspot.com/o/product_images%2FImageNotFound.jpeg?alt=media&token=856abe68-93b5-49e9-91bc-006c8e6f399a")
            await firebase_storage.FirebaseStorage.instance.refFromURL(currentImageUrl).delete();
          }

          // Update the existing document with the new details
          await db.collection("products")
              .doc(existingProduct.docs.first.id)
              .update(product);
        }
      } else {
        // Adding a new product
        db.collection("products").add(product).then((DocumentReference doc) =>
            print('DocumentSnapshot added with ID: ${doc.id}'));
      }

      Navigator.of(context).pop();
    }
  }

  Future<String> _getCategoryId(String categoryName) async {
    try {
      // Reference to the 'category' collection in Firestore
      CollectionReference categoryCollection = FirebaseFirestore.instance
          .collection('Category');

      // Query for the category with the given name
      QuerySnapshot categorySnapshot = await categoryCollection.where(
          'categoryName', isEqualTo: categoryName).get();

      // Check if any documents match the query
      if (categorySnapshot.docs.isNotEmpty) {
        // Retrieve the first document and return its ID as the category ID
        return categorySnapshot.docs.first.id;
      } else {
        // Handle the case when the category is not found
        print('Category not found for name: $categoryName');
        // You can choose to throw an exception or return a default value here
        // For now, let's return an empty string
        return '';
      }
    } catch (e) {
      // Handle any errors that might occur during the Firestore query
      print('Error retrieving category ID: $e');
      // You can choose to throw an exception or return a default value here
      // For now, let's return an empty string
      return '';
    }
  }

  Future<String> _uploadImageToFirebaseStorage(File imageFile) async {
    try {
      // Determine the file extension from the file name
      String fileExtension = imageFile.path
          .split('.')
          .last
          .toLowerCase();

      // Define a map of content types based on file extensions
      Map<String, String> contentTypes = {
        'png': 'image/png',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'webp': 'image/webp',
      };

      // Get the content type based on the file extension
      String? contentType = contentTypes[fileExtension];

      if (contentType == null) {
        print('Unsupported file type: $fileExtension');
        return ''; // You can handle this case according to your needs
      }

      // Create metadata with the determined content type
      firebase_storage.SettableMetadata metadata = firebase_storage
          .SettableMetadata(
        contentType: contentType,
      );

      // Create a reference to the storage location
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("product_images")
          .child("${DateTime
          .now()
          .millisecondsSinceEpoch}.$fileExtension");

      // Upload the file with the specified metadata
      firebase_storage.UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() => null);

      // Get the download URL of the uploaded file
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

}

