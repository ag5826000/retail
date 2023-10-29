import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop_app/models/Cart.dart';

import '../../../size_config.dart';
import 'cart_card.dart';

class Body extends StatefulWidget {
  final VoidCallback updateTotal;
  Body({required this.updateTotal});
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  void onRemove(Cart cart) {
    setState(() {
      if (cart.numOfItem > 1) {
        cart.numOfItem--;
      } else {
        // Remove the item from the list if the quantity is 1
        demoCartsMap.remove(cart.item.barcode);
      }
      widget.updateTotal();
    });
  }

  void onAdd(Cart cart) {
    setState(() {
      cart.numOfItem++;
      widget.updateTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
      child: ListView(
        children: demoCartsMap.values.map((cart) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Dismissible(
              key: Key(cart.item.barcode),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                setState(() {
                  demoCartsMap.remove(cart.item.barcode);
                  widget.updateTotal();
                });
              },
              background: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Color(0xFFFFE6E6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Spacer(),
                    SvgPicture.asset("assets/icons/Trash.svg"),
                  ],
                ),
              ),
              child: CartCard(
                cart: cart,
                onRemove: () => onRemove(cart),
                onAdd: () => onAdd(cart),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}