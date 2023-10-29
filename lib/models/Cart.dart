

import 'package:flutter/material.dart';

import 'Product.dart';

class CartItem
{
  String title;
  int price;
  String barcode;
  CartItem({required this.title, required this.price,required this.barcode});
}

class Cart {
  final CartItem item;
  int numOfItem;

  Cart({required this.item, required this.numOfItem});

  Map<String, dynamic> toMap() {
    return {
      'title': item.title,
      'price':item.price,
      'barcode':item.barcode,
      'numOfItem': numOfItem,
    };
  }
}

// Demo data for our cart

Map<String, Cart> demoCartsMap = {
};
