import 'package:flutter/material.dart';
import '../../../size_config.dart';

class DiscountBanner extends StatelessWidget {
  final List<String?> values;
  final List<String?> titles;

  DiscountBanner({Key? key, required this.values, required this.titles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(getProportionateScreenWidth(7)),
      padding: EdgeInsets.all(getProportionateScreenWidth(25)),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(
          values.length,
              (index) => Container(
            width: MediaQuery.of(context).size.width /3.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  titles[index]!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getProportionateScreenWidth(12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: getProportionateScreenWidth(10)),
                Text(
                  values[index]!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getProportionateScreenWidth(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

            ),
          ),
        )

      ),
    );
  }
}
