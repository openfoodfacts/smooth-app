import 'package:intl/intl.dart';
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



  void launchURL(String url, bool isOFF ) async{

    String openURL;


    if(isOFF){
      final String locale = Intl.getCurrentLocale();
      openURL = StringUtils.addCharAtPosition(url, '${locale ?? 'en'}.', 8);
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