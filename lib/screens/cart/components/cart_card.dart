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
  }) : super(key: key);

  final Cart cart;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: AspectRatio(
            aspectRatio: 0.88,
            child: Container(
              padding: EdgeInsets.all(getProportionateScreenWidth(10)),
              decoration: BoxDecoration(
                color: Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.asset(cart.product.images[0]),
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cart.product.title,
              style: TextStyle(color: Colors.black, fontSize: 16),
              maxLines: 2,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text.rich(
                  TextSpan(
                    text: "\$${cart.product.price}",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: kPrimaryColor),
                    children: [
                      TextSpan(
                          text: " x${cart.numOfItem}",
                          style: Theme.of(context).textTheme.bodyText1),
                    ],
                  ),

                ),
                Expanded( // Wrap the nested Row with Expanded
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: onRemove,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.red, // Customize the button color
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onAdd,
                        child: Container(
                          // margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: kPrimaryColor, // Customize the button color
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
                ),
              ],
            ),

          ],
        ),
        ),
      ],
    );
  }
}
