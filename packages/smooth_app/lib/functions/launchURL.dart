import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:basic_utils/basic_utils.dart';


class Launcher{

  ///
  /// ifOFF (is Open food facts)
  /// when true add language identifier at start
  ///
  /// !!!
  /// NO  https://de.openfoodfacts.org/...
  /// YES https://   openfoodfacts.org/...
  /// !!!
  ///



  void launchURL(BuildContext context, String url, bool isOFF ) async{

    String openURL;

    if(isOFF){
      Locale locale = Localizations.localeOf(context);
      openURL = StringUtils.addCharAtPosition(url, '${locale.countryCode.toString()}', 8);
      print(openURL);
    }
    else{
      openURL = url;
    }

    if (await canLaunch(openURL)) {
      await launch(openURL);
    } else {
      throw 'Could not launch $url';
    }
    return;
  }


}