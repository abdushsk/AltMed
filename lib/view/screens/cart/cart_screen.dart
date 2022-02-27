import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_divider.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/main_app_bar.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/screens/cart/widget/cart_product_widget.dart';
import 'package:flutter_grocery/view/screens/cart/widget/delivery_option_button.dart';
import 'package:flutter_grocery/view/screens/checkout/checkout_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class CartScreen extends StatefulWidget {
  final bool activated;

  const CartScreen({Key key, this.activated}) : super(key: key);
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ImagePicker picker = ImagePicker();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _couponController = TextEditingController();
  bool temp = false;
  bool reloaded = false;

  void skip() {
    if (!reloaded) {
      Timer(Duration(seconds: 1), () {
        print("yoyo " + temp.toString());
        setState(() {});
      });
      reloaded = true;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // countPrescription();
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    // final _CartScreenState state = CartScreen.of(context);
    // state
    // });
    Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
    bool _isSelfPickupActive =
        Provider.of<SplashProvider>(context, listen: false)
                .configModel
                .selfPickup ==
            1;
    bool _kmWiseCharge = Provider.of<SplashProvider>(context, listen: false)
            .configModel
            .deliveryManagement
            .status ==
        1;

    return Scaffold(
      key: _scaffoldKey,
      appBar: ResponsiveHelper.isMobilePhone()
          ? (widget.activated
              ? CustomAppBar(
                  title: "Cart",
                  isCenter: false,
                  isElevation: true,
                )
              : null)
          : ResponsiveHelper.isDesktop(context)
              ? MainAppBar()
              : AppBarBase(),
      body: Center(
        child: Consumer<CartProvider>(
          builder: (context, cart, child) {
            double deliveryCharge = 0;
            (Provider.of<OrderProvider>(context).orderType == 'delivery' &&
                    !_kmWiseCharge)
                ? deliveryCharge =
                    Provider.of<SplashProvider>(context, listen: false)
                        .configModel
                        .deliveryCharge
                : deliveryCharge = 0;
            double _itemPrice = 0;
            double _discount = 0;
            double _tax = 0;
            cart.cartList.forEach((cartModel) {
              _itemPrice = _itemPrice + (cartModel.price * cartModel.quantity);
              _discount = _discount + (cartModel.discount * cartModel.quantity);
              _tax = _tax + (cartModel.tax * cartModel.quantity);
            });
            double _subTotal = _itemPrice + _tax;
            double _total = _subTotal -
                _discount -
                Provider.of<CouponProvider>(context).discount +
                deliveryCharge;

            return (cart.cartList.length > 0 ||
                    Provider.of<CartProvider>(context, listen: false)
                            .pickedImages
                            .length >
                        0 ||
                    Provider.of<CartProvider>(context, listen: false)
                            .pickedPDF !=
                        null)
                ? Column(
                    children: [
                      Expanded(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            physics: BouncingScrollPhysics(),
                            child: Center(
                              child: SizedBox(
                                width: 1170,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: cart.cartList.length,
                                        itemBuilder: (context, index) {
                                          if (cart.cartList[index]
                                                  .prescriptionRequired ==
                                              'yes') {
                                            temp = true;
                                            skip();
                                          }
                                          return Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10))),
                                                child: Stack(children: [
                                                  Positioned(
                                                    top: 0,
                                                    bottom: 0,
                                                    right: 0,
                                                    left: 0,
                                                    child: Icon(Icons.delete,
                                                        color: Colors.white,
                                                        size: 50),
                                                  ),
                                                  Dismissible(
                                                    key: UniqueKey(),
                                                    onDismissed:
                                                        (DismissDirection
                                                            direction) {
                                                      if (cart.cartList[index]
                                                              .prescriptionRequired ==
                                                          'yes') {
                                                        temp = false;
                                                        reloaded = false;
                                                        skip();
                                                      }
                                                      Provider.of<CouponProvider>(
                                                              context,
                                                              listen: false)
                                                          .removeCouponData(
                                                              false);
                                                      Provider.of<CartProvider>(
                                                              context,
                                                              listen: false)
                                                          .removeFromCart(
                                                              index, context);
                                                    },
                                                    child: Container(
                                                      height: 95,
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: Dimensions
                                                              .PADDING_SIZE_EXTRA_SMALL,
                                                          horizontal: Dimensions
                                                              .PADDING_SIZE_SMALL),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .cardColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .grey[Provider.of<
                                                                            ThemeProvider>(
                                                                        context)
                                                                    .darkTheme
                                                                ? 700
                                                                : 300],
                                                            blurRadius: 5,
                                                            spreadRadius: 1,
                                                          )
                                                        ],
                                                      ),
                                                      child: Row(children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: FadeInImage
                                                              .assetNetwork(
                                                            placeholder: Images
                                                                .placeholder,
                                                            image:
                                                                '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${cart.cartList[index].image}',
                                                            height: 70,
                                                            width: 85,
                                                            imageErrorBuilder: (c,
                                                                    o, s) =>
                                                                Image.asset(
                                                                    Images
                                                                        .placeholder,
                                                                    height: 70,
                                                                    width: 85),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: Dimensions
                                                                .PADDING_SIZE_SMALL),
                                                        Expanded(
                                                            child: Column(
                                                          children: [
                                                            SizedBox(
                                                                height: 10),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                        cart
                                                                            .cartList[
                                                                                index]
                                                                            .name,
                                                                        style: poppinsRegular.copyWith(
                                                                            fontSize: Dimensions
                                                                                .FONT_SIZE_SMALL),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis)),
                                                                Text(
                                                                  PriceConverter.convertPrice(
                                                                      context,
                                                                      cart
                                                                          .cartList[
                                                                              index]
                                                                          .price),
                                                                  style: poppinsSemiBold
                                                                      .copyWith(
                                                                          fontSize:
                                                                              Dimensions.FONT_SIZE_SMALL),
                                                                ),
                                                                SizedBox(
                                                                    width: 10),
                                                              ],
                                                            ),
                                                            SizedBox(height: 5),
                                                            Row(children: [
                                                              Expanded(
                                                                  child: Text(
                                                                      '${cart.cartList[index].capacity} ${cart.cartList[index].unit}',
                                                                      style: poppinsRegular.copyWith(
                                                                          fontSize:
                                                                              Dimensions.FONT_SIZE_SMALL))),
                                                              InkWell(
                                                                onTap: () {
                                                                  if (cart
                                                                          .cartList[
                                                                              index]
                                                                          .prescriptionRequired ==
                                                                      'yes') {
                                                                    temp =
                                                                        false;
                                                                    reloaded =
                                                                        false;
                                                                    skip();
                                                                  }
                                                                  Provider.of<CouponProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .removeCouponData(
                                                                          false);
                                                                  if (cart
                                                                          .cartList[
                                                                              index]
                                                                          .quantity >
                                                                      1) {
                                                                    Provider.of<CartProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .setQuantity(
                                                                            false,
                                                                            index);
                                                                  } else if (cart
                                                                          .cartList[
                                                                              index]
                                                                          .quantity ==
                                                                      1) {
                                                                    Provider.of<CartProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .removeFromCart(
                                                                            index,
                                                                            context);
                                                                  }
                                                                },
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          Dimensions
                                                                              .PADDING_SIZE_SMALL,
                                                                      vertical:
                                                                          Dimensions
                                                                              .PADDING_SIZE_EXTRA_SMALL),
                                                                  child: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      size: 20,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor),
                                                                ),
                                                              ),
                                                              Text(
                                                                  cart
                                                                      .cartList[
                                                                          index]
                                                                      .quantity
                                                                      .toString(),
                                                                  style: poppinsSemiBold.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .FONT_SIZE_EXTRA_LARGE,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor)),
                                                              InkWell(
                                                                onTap: () {
                                                                  if (cart
                                                                          .cartList[
                                                                              index]
                                                                          .quantity <
                                                                      cart
                                                                          .cartList[
                                                                              index]
                                                                          .stock) {
                                                                    Provider.of<CouponProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .removeCouponData(
                                                                            false);
                                                                    Provider.of<CartProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .setQuantity(
                                                                            true,
                                                                            index);
                                                                  } else {
                                                                    showCustomSnackBar(
                                                                        getTranslated(
                                                                            'out_of_stock',
                                                                            context),
                                                                        context);
                                                                  }
                                                                },
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          Dimensions
                                                                              .PADDING_SIZE_SMALL,
                                                                      vertical:
                                                                          Dimensions
                                                                              .PADDING_SIZE_EXTRA_SMALL),
                                                                  child: Icon(
                                                                      Icons.add,
                                                                      size: 20,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor),
                                                                ),
                                                              ),
                                                            ]),
                                                          ],
                                                        )),
                                                        !ResponsiveHelper
                                                                .isMobile(
                                                                    context)
                                                            ? Padding(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        Dimensions
                                                                            .PADDING_SIZE_SMALL),
                                                                child:
                                                                    IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    Provider.of<CartProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .removeFromCart(
                                                                            index,
                                                                            context);
                                                                  },
                                                                  icon: Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                              )
                                                            : SizedBox(),
                                                      ]),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              // cart.prescriptionRequired == 'yes'
                                              //     ? Column(
                                              //   children: [
                                              //     Container(
                                              //         width: double.infinity,
                                              //         color: Colors.white,
                                              //         child: Padding(
                                              //           padding: const EdgeInsets.only(left: 8.0),
                                              //           child: Text('Upload Prescription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, backgroundColor: Colors.white),),
                                              //         )),
                                              //
                                              //     Container(
                                              //       margin: EdgeInsets.only(bottom: 24),
                                              //       alignment: Alignment.center,
                                              //       decoration: BoxDecoration(
                                              //         border: Border.all(color: Colors.white, width: 3),
                                              //         shape: BoxShape.rectangle,
                                              //       ),
                                              //       child: InkWell(
                                              //         onTap: () {
                                              //           if(ResponsiveHelper.isMobilePhone()) {
                                              //             Provider.of<OrderProvider>(context, listen: false).choosePhoto(index, context);
                                              //           }else {
                                              //             Provider.of<OrderProvider>(context, listen: false).choosePhoto(index, context);
                                              //           }
                                              //         },
                                              //         child: Stack(
                                              //           clipBehavior: Clip.none,
                                              //           children: [
                                              //             Container(
                                              //               child: (Provider.of<OrderProvider>(context, listen: false).exists(index))
                                              //                   ? Image.file(File(Provider.of<OrderProvider>(context, listen: false).CartList[index].prescriptionImage), width: 80, height: 80, fit: BoxFit.cover,) :  ClipRRect(
                                              //                 borderRadius: BorderRadius.circular(50),
                                              //                 child: FadeInImage.assetNetwork(
                                              //                   placeholder: Images.placeholder,
                                              //                   width: 40, height: 40, fit: BoxFit.cover,
                                              //                   // image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.customerImageUrl}'
                                              //                   //     '/${profileProvider.userInfoModel.image}',
                                              //                   image: '',
                                              //                   imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 80, width: 80, fit: BoxFit.cover),
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //             Positioned(
                                              //               bottom: 5,
                                              //               right: 0,
                                              //               child: Image.asset(
                                              //                 Images.camera,
                                              //                 width: 24,
                                              //                 height: 24,
                                              //               ),
                                              //             ),
                                              //           ],
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ) : Text(''),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(
                                          height:
                                              Dimensions.PADDING_SIZE_LARGE),

                                      temp == true
                                          ? Column(
                                              children: [
                                                Container(
                                                    width: double.infinity,
                                                    color: Colors.white,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Text(
                                                        'Upload Prescription',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10,
                                                            backgroundColor:
                                                                Colors.white),
                                                      ),
                                                    )),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 24),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 3),
                                                    shape: BoxShape.rectangle,
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            15.0),
                                                                child: Text(
                                                                    'Upload Prescription'),
                                                              ),
                                                              actions: [
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    Provider.of<OrderProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .choosePhotoFromCamera(
                                                                            0,
                                                                            context);
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .camera_alt,
                                                                    color: ColorResources
                                                                        .getHintColor(
                                                                            context),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 24),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          80.0),
                                                                  child:
                                                                      InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      Provider.of<OrderProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .choosePhoto(
                                                                              0,
                                                                              context);
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .insert_photo,
                                                                      color: ColorResources
                                                                          .getHintColor(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                    },
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Container(
                                                          child: (Provider.of<
                                                                          OrderProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .exists(0))
                                                              ? Image.file(
                                                                  File(Provider.of<
                                                                              OrderProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .CartList[
                                                                          0]
                                                                      .prescriptionImage),
                                                                  width: 80,
                                                                  height: 80,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50),
                                                                  child: FadeInImage
                                                                      .assetNetwork(
                                                                    placeholder:
                                                                        Images
                                                                            .placeholder,
                                                                    width: 40,
                                                                    height: 40,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    // image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.customerImageUrl}'
                                                                    //     '/${profileProvider.userInfoModel.image}',
                                                                    image: '',
                                                                    imageErrorBuilder: (c, o, s) => Image.asset(
                                                                        Images
                                                                            .placeholder,
                                                                        height:
                                                                            80,
                                                                        width:
                                                                            80,
                                                                        fit: BoxFit
                                                                            .cover),
                                                                  ),
                                                                ),
                                                        ),
                                                        Positioned(
                                                          bottom: 5,
                                                          right: 0,
                                                          child: Image.asset(
                                                            Images.camera,
                                                            width: 24,
                                                            height: 24,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      // Coupon
                                      Consumer<CouponProvider>(
                                        builder: (context, coupon, child) {
                                          return Row(children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _couponController,
                                                style: poppinsMedium,
                                                decoration: InputDecoration(
                                                    hintText: getTranslated(
                                                        'enter_promo_code',
                                                        context),
                                                    hintStyle:
                                                        poppinsRegular.copyWith(
                                                            color: ColorResources
                                                                .getHintColor(
                                                                    context)),
                                                    isDense: true,
                                                    filled: true,
                                                    enabled:
                                                        coupon.discount == 0,
                                                    fillColor: Theme.of(context)
                                                        .cardColor,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.horizontal(
                                                                left:
                                                                    Radius.circular(10)),
                                                        borderSide: BorderSide.none)),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (_couponController
                                                        .text.isNotEmpty &&
                                                    !coupon.isLoading) {
                                                  if (coupon.discount < 1) {
                                                    coupon
                                                        .applyCoupon(
                                                            _couponController
                                                                .text,
                                                            _total)
                                                        .then((discount) {
                                                      if (discount > 0) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              'You got ${PriceConverter.convertPrice(context, discount)} discount'),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ));
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              getTranslated(
                                                                  'invalid_code_or_failed',
                                                                  context)),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ));
                                                      }
                                                    });
                                                  } else {
                                                    coupon
                                                        .removeCouponData(true);
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(getTranslated(
                                                        'enter_a_coupon_code',
                                                        context)),
                                                    backgroundColor: Colors.red,
                                                  ));
                                                }
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 100,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  borderRadius:
                                                      BorderRadius.horizontal(
                                                    right: Radius.circular(
                                                        Provider.of<LocalizationProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .isLtr
                                                            ? 10
                                                            : 0),
                                                    left: Radius.circular(
                                                        Provider.of<LocalizationProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .isLtr
                                                            ? 0
                                                            : 10),
                                                  ),
                                                ),
                                                child: coupon.discount <= 0
                                                    ? !coupon.isLoading
                                                        ? Text(
                                                            getTranslated(
                                                                'apply',
                                                                context),
                                                            style: poppinsMedium
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white),
                                                          )
                                                        : CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    Colors
                                                                        .white))
                                                    : Icon(Icons.clear,
                                                        color: Colors.white),
                                              ),
                                            ),
                                          ]);
                                        },
                                      ),
                                      SizedBox(
                                          height:
                                              Dimensions.PADDING_SIZE_LARGE),

                                      // Order type
                                      _isSelfPickupActive
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                  //  PRESCRIPTION START
                                                  if (Provider.of<CartProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .pickedPDF !=
                                                          null ||
                                                      Provider.of<CartProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .pickedImages
                                                              .length >
                                                          0)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            25,
                                                        // height: MediaQuery.of(context).size.height * 18 / 100,
                                                        decoration: BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        10.0)),
                                                            color: ColorResources
                                                                .getCardBgColor(
                                                                    context),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                blurRadius: 0.5,
                                                              ),
                                                            ]),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  "Prescription Added",
                                                                  style: poppinsMedium
                                                                      .copyWith(
                                                                          fontSize:
                                                                              Dimensions.FONT_SIZE_LARGE)),
                                                              if (Provider.of<CartProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .pickedImages
                                                                      .length >
                                                                  0)
                                                                Container(
                                                                  height: 90,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              15),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        for (var i = Provider.of<CartProvider>(context, listen: false).pickedImages.length -
                                                                                1;
                                                                            i >=
                                                                                0;
                                                                            i--)
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 15),
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                Image.file(
                                                                                  Provider.of<CartProvider>(context, listen: false).pickedImages[i],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  // PRESCRIPTION END
                                                  Text(
                                                      getTranslated(
                                                          'delivery_option',
                                                          context),
                                                      style: poppinsMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_LARGE)),
                                                  DeliveryOptionButton(
                                                      value: 'delivery',
                                                      title: getTranslated(
                                                          'delivery', context),
                                                      kmWiseFee: _kmWiseCharge),
                                                  DeliveryOptionButton(
                                                      value: 'self_pickup',
                                                      title: getTranslated(
                                                          'self_pickup',
                                                          context),
                                                      kmWiseFee: _kmWiseCharge),
                                                  SizedBox(
                                                      height: Dimensions
                                                          .PADDING_SIZE_LARGE),
                                                ])
                                          : SizedBox(),

                                      // Total
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                getTranslated(
                                                    'items_price', context),
                                                style: poppinsRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_LARGE)),
                                            Text(
                                                PriceConverter.convertPrice(
                                                    context, _itemPrice),
                                                style: poppinsRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_LARGE)),
                                          ]),
                                      SizedBox(height: 10),

                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(getTranslated('tax', context),
                                                style: poppinsRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_LARGE)),
                                            Text(
                                                '(+) ${PriceConverter.convertPrice(context, _tax)}',
                                                style: poppinsRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_LARGE)),
                                          ]),
                                      SizedBox(height: 10),

                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                getTranslated(
                                                    'discount', context),
                                                style: poppinsRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_LARGE)),
                                            Text(
                                                '(-) ${PriceConverter.convertPrice(context, _discount)}',
                                                style: poppinsRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_LARGE)),
                                          ]),
                                      SizedBox(height: 10),

                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                getTranslated(
                                                    'coupon_discount', context),
                                                style: poppinsRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_LARGE)),
                                            Text(
                                              '(-) ${PriceConverter.convertPrice(context, Provider.of<CouponProvider>(context).discount)}',
                                              style: poppinsRegular.copyWith(
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_LARGE),
                                            ),
                                          ]),
                                      SizedBox(height: 10),

                                      _kmWiseCharge
                                          ? SizedBox()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                  Text(
                                                    getTranslated(
                                                        'delivery_fee',
                                                        context),
                                                    style:
                                                        poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE),
                                                  ),
                                                  Text(
                                                    '(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
                                                    style:
                                                        poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE),
                                                  ),
                                                ]),

                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                Dimensions.PADDING_SIZE_SMALL),
                                        child: CustomDivider(),
                                      ),

                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                getTranslated(
                                                    _kmWiseCharge
                                                        ? 'subtotal'
                                                        : 'total_amount',
                                                    context),
                                                style: poppinsMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_EXTRA_LARGE,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )),
                                            Text(
                                              PriceConverter.convertPrice(
                                                  context, _total),
                                              style: poppinsMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_EXTRA_LARGE,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          ]),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1170,
                        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        child: CustomButton(
                          buttonText:
                              getTranslated('continue_checkout', context),
                          onPressed: () {
                            if (_itemPrice <
                                    Provider.of<SplashProvider>(context,
                                            listen: false)
                                        .configModel
                                        .minimumOrderValue &&
                                Provider.of<CartProvider>(context,
                                            listen: false)
                                        .pickedImages
                                        .length ==
                                    0 &&
                                Provider.of<CartProvider>(context,
                                            listen: false)
                                        .pickedPDF ==
                                    null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Text(
                                        'Minimum order amount is ${PriceConverter.convertPrice(context, Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue)}, you have ${PriceConverter.convertPrice(context, _itemPrice)} in your cart, please add more item.',
                                      ),
                                      backgroundColor: Colors.red));
                            } else {
                              String _orderType = Provider.of<OrderProvider>(
                                      context,
                                      listen: false)
                                  .orderType;
                              double _discount = Provider.of<CouponProvider>(
                                      context,
                                      listen: false)
                                  .discount;
                              Navigator.pushNamed(
                                context,
                                RouteHelper.getCheckoutRoute(
                                  _total,
                                  _discount,
                                  _orderType,
                                  Provider.of<CouponProvider>(context,
                                          listen: false)
                                      .code,
                                ),
                                arguments: CheckoutScreen(
                                  amount: _total,
                                  orderType: _orderType,
                                  discount: _discount,
                                  couponCode: Provider.of<CouponProvider>(
                                          context,
                                          listen: false)
                                      .code,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : NoDataScreen(isCart: true);
          },
        ),
      ),
    );
  }
}
