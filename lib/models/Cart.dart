

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'Product.dart';

class CartItem
{
  String productId;
  String title;
  int price;
  String barcode;
  String category;
  CartItem({required this.title, required this.price,required this.barcode,required this.category, required this.productId});
     // CartItem({required this.productId})
}

class Cart {
  final CartItem item;
  int numOfItem;

  Cart({required this.item, required this.numOfItem});

  Map<String, dynamic> toMap() {
    return {
      // 'title': item.title,
      // 'price':item.price,
      // 'barcode':item.barcode,
      // 'category' :item.category,
      'productId': item.productId,
      'numOfItem': numOfItem,
    };
  }
}

// Demo data for our cart

Map<String, Cart> demoCartsMap = {
};
