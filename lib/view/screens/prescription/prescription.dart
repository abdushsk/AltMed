import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/main_app_bar.dart';
import 'package:flutter_grocery/view/screens/product/widget/details_app_bar.dart';

class PrescriptionScreen extends StatefulWidget {
  PrescriptionScreen();

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  List<File> pickedImages = [];
  File pickedPdf;

  _getFromGallery() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        pickedPdf = null;
        pickedImages.add(imageFile);
      });
    }
  }

  _getPdf() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        pickedPdf = File(result.files.single.path);

        pickedImages = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("File Uploaded"),
        backgroundColor: Colors.green,
      ));
    } else {
      // User canceled the picker
    }
  }

  _getFromCamera() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        pickedImages.add(imageFile);
        pickedPdf = null;
      });
    }
  }

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
              Container(
                width: MediaQuery.of(context).size.width - 25,
                // height: MediaQuery.of(context).size.height * 18 / 100,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: ColorResources.getCardBgColor(context),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 0.5,
                      ),
                    ]),
                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "UPLOAD",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Please Upload images of valid prescriptions from your doctor.",
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _getFromCamera();
                                },
                                child:
                                    Icon(Icons.camera_alt, color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(25),
                                  primary: Colors.blue, // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Camera"),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _getFromGallery();
                                },
                                child: Icon(Icons.photo_rounded,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(25),
                                  primary: Colors.blue, // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Gallery"),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _getPdf();
                                },
                                child: Icon(Icons.picture_as_pdf,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(25),
                                  primary: Colors.blue, // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text("PDF"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (pickedImages.length > 0)
                      Container(
                        height: 90,
                        margin: EdgeInsets.only(top: 15),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              for (var i = pickedImages.length - 1; i >= 0; i--)
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Stack(
                                    children: [
                                      Image.file(
                                        pickedImages[i],
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("VALID PRISCRIPTION GUIDE",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500)),
                      Text(
                        "Image should be sharp and contain below mentioned 4 points",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Image.asset("assets/image/valid.png"),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width - 100,
                decoration: BoxDecoration(),
                child: TextButton(
                  onPressed: () {
                    if (pickedImages.length == 0 && pickedPdf == null) {
                      return;
                    }
                    Provider.of<CartProvider>(context, listen: false)
                        .pickedImages = pickedImages;
                    Provider.of<CartProvider>(context, listen: false)
                        .pickedPDF = pickedPdf;
                    Navigator.pushNamed(
                        context, RouteHelper.categorys + "?activated=true");
                  },
                  style: ButtonStyle(
                      // backgroundColor:
                      //     MaterialStateProperty.all<Color>(Colors.grey[200]),
                      ),
                  child: Center(
                    child: Container(
                      child: Text(
                        "CONTINUE",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color:
                                (pickedImages.length == 0 && pickedPdf == null)
                                    ? Colors.black26
                                    : null),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
