
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/screens/cart/cart_screen.dart';
import 'package:shop_app/screens/cart/components/scanner.dart';
import 'package:shop_app/screens/history/history_screen.dart';
import 'package:shop_app/screens/home/home_screen.dart';
import 'package:shop_app/screens/profile/profile_screen.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../constants.dart';
import '../enums.dart';
import 'package:audioplayers/audioplayers.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    Key? key,
    required this.selectedMenu,
  }) : super(key: key);

  final MenuState selectedMenu;


  @override
  Widget build(BuildContext context) {
    final Color inActiveIconColor = Colors.black;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -15),
            blurRadius: 20,
            color: Color(0xFFDADADA).withOpacity(0.15),
          ),
        ],
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(20),
        //   topRight: Radius.circular(20),
        // ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: MenuState.home == selectedMenu
                  ? null
                  : () => Navigator.pushNamed(context, HomeScreen.routeName),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/Shop Icon.svg",
                      color: MenuState.home == selectedMenu
                          ? kPrimaryColor
                          : inActiveIconColor,
                    ),
                    onPressed: MenuState.home == selectedMenu
                        ? null
                        : () => Navigator.pushNamed(context, HomeScreen.routeName),
                  ),
                  Transform.translate(
                    offset: Offset(0.0, -8.0), // Adjust the offset as needed
                    child: GestureDetector(
                      onTap: MenuState.home == selectedMenu
                          ? null
                          : () => Navigator.pushNamed(context, HomeScreen.routeName),
                      child: Text(
                        "Home",
                        style: TextStyle(
                          color: MenuState.home == selectedMenu
                              ? kPrimaryColor
                              : inActiveIconColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: MenuState.favourite == selectedMenu
                  ? null
                  : () => Navigator.pushNamed(context, HistoryScreen.routeName),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/transaction.svg",
                      color: MenuState.favourite == selectedMenu
                          ? kPrimaryColor
                          : inActiveIconColor,
                    ),
                    onPressed: MenuState.favourite == selectedMenu
                        ? null
                        : () => Navigator.pushNamed(context, HistoryScreen.routeName),
                  ),
                  Transform.translate(
                    offset: Offset(0.0, -8.0), // Adjust the offset as needed
                    child: GestureDetector(
                      onTap: MenuState.favourite == selectedMenu
                          ? null
                          : () => Navigator.pushNamed(context, HistoryScreen.routeName),
                      child: Text(
                        "Transactions",
                        style: TextStyle(
                          color: MenuState.favourite == selectedMenu
                              ? kPrimaryColor
                              : inActiveIconColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap:  MenuState.message == selectedMenu ? null:() => Navigator.pushNamed(context, CartScreen.routeName),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/Cart Icon.svg",
                      color: MenuState.message == selectedMenu
                          ? kPrimaryColor
                          : inActiveIconColor,
                    ),
                    onPressed:  MenuState.message == selectedMenu ? null:() => Navigator.pushNamed(context, CartScreen.routeName),
                  ),
                  Transform.translate(
                    offset: Offset(0.0, -8.0), // Adjust the offset as needed
                    child: GestureDetector(
                      onTap:  MenuState.message == selectedMenu ? null:() => Navigator.pushNamed(context, CartScreen.routeName),
                      child: Text(
                        "Cart",
                        style: TextStyle(
                          color: MenuState.message == selectedMenu
                              ? kPrimaryColor
                              : inActiveIconColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: MenuState.profile == selectedMenu
                  ? null
                  : () => Navigator.pushNamed(context, ProfileScreen.routeName),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/User Icon.svg",
                      color: MenuState.profile == selectedMenu
                          ? kPrimaryColor
                          : inActiveIconColor,
                    ),
                    onPressed: MenuState.profile == selectedMenu
                        ? null
                        : () => Navigator.pushNamed(context, ProfileScreen.routeName),
                  ),
                  Transform.translate(
                    offset: Offset(0.0, -8.0), // Adjust the offset as needed
                    child: GestureDetector(
                      onTap: MenuState.profile == selectedMenu
                          ? null
                          : () => Navigator.pushNamed(context, ProfileScreen.routeName),
                      child: Text(
                        "Profile",
                        style: TextStyle(
                          color: MenuState.profile == selectedMenu
                              ? kPrimaryColor
                              : inActiveIconColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
