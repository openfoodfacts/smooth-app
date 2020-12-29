import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:basic_utils/basic_utils.dart';


class Launcher{

  ///
  /// ifOFF (is Open Food Facts)
  /// when true add language identifier at start
  ///
  /// !!!
  /// NO  https://de.openfoodfacts.org/...
  /// YES https://   openfoodfacts.org/...
  /// !!!
  ///



  Future<void> launchURL(BuildContext context, String url, bool isOFF ) async{

    String openURL;
    String localeString;

    if(isOFF){
        final Locale locale = Localizations.localeOf(context);
        if(locale.countryCode.toString() == null){
          localeString = 'world.';
        }
        else{
          localeString = '${locale.countryCode.toString()}.';
        }
        openURL = StringUtils.addCharAtPosition(url, '$localeString', 8);
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
