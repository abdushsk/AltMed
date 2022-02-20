import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/view/base/main_app_bar.dart';
import 'package:flutter_grocery/view/screens/product/widget/details_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PrescriptionScreen extends StatelessWidget {
  PrescriptionScreen();

  @override
  Widget build(BuildContext context) {
    Provider.of<CartProvider>(context, listen: false).getCartData();

    Variations _variation;
    final GlobalKey<DetailsAppBarState> _key = GlobalKey();

    return Scaffold(
        backgroundColor: ColorResources.getBackgroundColor(context),
        appBar: ResponsiveHelper.isDesktop(context)
            ? MainAppBar()
            : DetailsAppBar(key: _key),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    "Upload",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
              Center(
                child: Container(
                  child: Image.asset("assets/image/valid.png"),
                ),
              )
            ],
          ),
        ));
  }
}
