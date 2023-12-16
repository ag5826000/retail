class CartItem
{
  String productId;
  String name;
  int price;
  String barcode;
  String categoryId;
  int mrp;
  String image;
  CartItem({required this.name, required this.price,required this.barcode,required this.categoryId,required this.productId,required this.mrp,required this.image});

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      "price": price,
      "barcode": barcode,
      "categoryId": categoryId,
      "mrp": mrp,
      "image": image,
    };
    }
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
      'numOfItem': numOfItem,
      'productId': item.productId,
      'sellingPrice':item.price,
    };
  }
}

// Demo data for our cart

Map<String, Cart> demoCartsMap = {
};
