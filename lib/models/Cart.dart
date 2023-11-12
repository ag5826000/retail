

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'Product.dart';

class CartItem
{
  String title;
  int price;
  String barcode;
  String category;
  CartItem({required this.title, required this.price,required this.barcode,required this.category});
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
      'category' :item.category,
      'numOfItem': numOfItem,
    };
  }
}

// Demo data for our cart

Map<String, Cart> demoCartsMap = {
};
