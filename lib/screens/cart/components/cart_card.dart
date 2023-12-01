import 'package:flutter/material.dart';
import 'package:shop_app/models/Cart.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class CartCard extends StatelessWidget {
  const CartCard({
    Key? key,
    required this.cart,
    required this.onRemove,
    required this.onAdd,
    required this.showProductDetailsPopup,
  }) : super(key: key);

  final Cart cart;
  final VoidCallback onRemove;
  final VoidCallback onAdd;
  final Function showProductDetailsPopup;

  void onEditPressed(BuildContext context) {
    print(cart.item.toMap());
    showProductDetailsPopup( cart.item.toMap(), cart.item.barcode, cart.item.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.white60.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.black45,
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.all(7),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: AspectRatio(
              aspectRatio: 0.88,
              child: Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(7)),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F6F9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.network(cart.item.image),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cart.item.name,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  maxLines: 2,
                ),

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    InkWell(
                      onTap: () => onEditPressed(context),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        InkWell(
                          onTap: onRemove,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          "${cart.numOfItem}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: onAdd,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text.rich(
                      TextSpan(
                        text: "₹${cart.item.price*cart.numOfItem}",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: kPrimaryColor,fontSize: 20),
                        // children: [
                        //   TextSpan(
                        //     text: " x${cart.numOfItem}",
                        //     style: Theme.of(context).textTheme.bodyText1,
                        //   ),
                        // ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
