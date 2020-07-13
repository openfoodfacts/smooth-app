import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:smooth_app/data_models/smooth_upload_model.dart';
import 'package:smooth_ui_library/buttons/smooth_main_button.dart';

enum PhotoType { FRONT, INGREDIENTS, NUTRITION_TABLE }

class SmoothUploadPage extends StatelessWidget {
  SmoothUploadPage({@required this.barcode});

  final String barcode;

  final ImagePicker imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider<SmoothUploadModel>(
        create: (BuildContext context) => SmoothUploadModel(),
    child: Consumer<SmoothUploadModel>(
      builder: (BuildContext context,
          SmoothUploadModel smoothUploadModel,
          Widget child) {
        return Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  margin: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Add a new product',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                _generatePicturePicker(
                    context, 'Product front', PhotoType.FRONT, Colors.lightBlueAccent, smoothUploadModel),
                _generatePicturePicker(context, 'Ingredients list',
                    PhotoType.INGREDIENTS, Colors.orangeAccent, smoothUploadModel),
                _generatePicturePicker(context, 'Nutrition-table',
                    PhotoType.NUTRITION_TABLE, Colors.deepPurpleAccent, smoothUploadModel),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 4.0,
                      sigmaY: 4.0,
                    ),
                    child: Container(
                      color: Colors.black12,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 20.0),
                      child: SmoothMainButton(
                        text: 'Send',
                        onPressed: () {
                          /*if(smoothUploadModel.frontPath != null && smoothUploadModel.ingredientsPath != null && smoothUploadModel.nutritionPath != null) {
                            final SendImage frontSendImage = SendImage(
                              lang: OpenFoodFactsLanguage.ENGLISH,
                              barcode: barcode,
                              imageField: ImageField.FRONT,
                              imageUrl: Uri.parse(smoothUploadModel.frontPath),
                            );
                            OpenFoodAPIClient.addProductImage(const User(), frontSendImage);
                            final SendImage ingredientsSendImage = SendImage(
                              lang: OpenFoodFactsLanguage.ENGLISH,
                              barcode: barcode,
                              imageField: ImageField.INGREDIENTS,
                              imageUrl: Uri.parse(smoothUploadModel.frontPath),
                            );
                            OpenFoodAPIClient.addProductImage(const User(), ingredientsSendImage);
                            final SendImage nutritionSendImage = SendImage(
                              lang: OpenFoodFactsLanguage.ENGLISH,
                              barcode: barcode,
                              imageField: ImageField.NUTRITION,
                              imageUrl: Uri.parse(smoothUploadModel.frontPath),
                            );
                            OpenFoodAPIClient.addProductImage(const User(), nutritionSendImage);
                          }*/
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),));
  }

  Widget _generatePicturePicker(
      BuildContext context, String title, PhotoType type, Color color, SmoothUploadModel model) {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 160.0,
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: color.withAlpha(50),
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withAlpha(32),
              blurRadius: 16.0,
              offset: const Offset(0.0, 8.0),
            )
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 12.0,
              ),
              SvgPicture.asset(
                getIconPath(type, model),
                width: 36.0,
                height: 36.0,
                color: color,
              ),
            ],
          ),
        ),
      ),
      onTap: () async {
        final PickedFile pickedFile =
            await imagePicker.getImage(source: ImageSource.camera);
        final File croppedFile = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Smooth crop',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
        );
        switch(type) {
          case PhotoType.FRONT:
            model.setFrontPath(croppedFile.path);
            break;
          case PhotoType.INGREDIENTS:
            model.setIngredientsPath(croppedFile.path);
            break;
          case PhotoType.NUTRITION_TABLE:
            model.setNutritionPath(croppedFile.path);
            break;
        }
      },
    );
  }

  String getIconPath(PhotoType type, SmoothUploadModel model) {
    switch(type) {
      case PhotoType.FRONT:
        return model.frontPath == null ? 'assets/actions/camera.svg' : 'assets/misc/checkmark.svg';
        break;
      case PhotoType.INGREDIENTS:
        return model.ingredientsPath == null ? 'assets/actions/camera.svg' : 'assets/misc/checkmark.svg';
        break;
      case PhotoType.NUTRITION_TABLE:
        return model.nutritionPath == null ? 'assets/actions/camera.svg' : 'assets/misc/checkmark.svg';
        break;
      default:
        return null;
        break;
    }
  }
}
