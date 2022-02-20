import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/banner_provider.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/main_app_bar.dart';
import 'package:flutter_grocery/view/base/title_widget.dart';
import 'package:flutter_grocery/view/screens/home/widget/banners_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/category_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/daily_item_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/product_view.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  Future<void> _loadData(BuildContext context, bool reload) async {
    // await Provider.of<CategoryProvider>(context, listen: false).getCategoryList(context, reload);

    await Provider.of<CategoryProvider>(context, listen: false).getCategoryList(
      context,
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .languageCode,
      reload,
    );
    await Provider.of<BannerProvider>(context, listen: false)
        .getBannerList(context, reload);
    await Provider.of<ProductProvider>(context, listen: false).getDailyItemList(
      context,
      reload,
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .languageCode,
    );
    // await Provider.of<ProductProvider>(context, listen: false).getPopularProductList(context, '1', true);
    Provider.of<ProductProvider>(context, listen: false).getPopularProductList(
      context,
      '1',
      reload,
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    _loadData(context, false);

    return RefreshIndicator(
      onRefresh: () async {
        await _loadData(context, true);
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? MainAppBar() : null,
        body: Scrollbar(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: SizedBox(
                width: 1170,
                child: Column(
                    // controller: _scrollController,
                    children: [
                      Consumer<BannerProvider>(
                          builder: (context, banner, child) {
                        return banner.bannerList == null
                            ? BannersView()
                            : banner.bannerList.length == 0
                                ? SizedBox()
                                : BannersView();
                      }),

                      // Category
                      Consumer<CategoryProvider>(
                          builder: (context, category, child) {
                        return category.categoryList == null
                            ? CategoryView()
                            : category.categoryList.length == 0
                                ? SizedBox()
                                : CategoryView();
                      }),

                      // CARD START

                      Container(
                        width: MediaQuery.of(context).size.width - 20,
                        // height: MediaQuery.of(context).size.height * 18 / 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: ColorResources.getCardBgColor(context),
                        ),
                        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order Medicine",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "Upload Prescription and tell us what you need. We do the rest!",
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 12,
                                        wordSpacing: 1,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400),
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Text(
                                    "Save Upto 60% Off",
                                    style: TextStyle(
                                        color: Colors.green.shade400,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  ElevatedButton(
                                    child: Text("Order Now"),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          RouteHelper.getPrescriptionRoute());
                                    },
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Image.asset(
                                "assets/image/medic.png",
                              ),
                            )
                          ],
                        ),
                      ),

                      // CARD END

                      // Category
                      Consumer<ProductProvider>(
                          builder: (context, product, child) {
                        return product.dailyItemList == null
                            ? DailyItemView()
                            : product.dailyItemList.length == 0
                                ? SizedBox()
                                : DailyItemView();
                      }),

                      // Popular Item
                      Padding(
                        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        child: TitleWidget(
                            title: getTranslated('popular_item', context)),
                      ),
                      ProductView(
                          productType: ProductType.POPULAR_PRODUCT,
                          scrollController: _scrollController),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
