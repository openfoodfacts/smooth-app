import 'package:flutter/material.dart';
import 'package:smooth_app/pages/smooth_upload_page.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';

class SmoothProductCardNotFound extends StatelessWidget {
  const SmoothProductCardNotFound({
    @required this.barcode,
    this.callback,
    this.elevation = 0.0,
  });

  final String barcode;
  final Function callback;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('This product is missing'),
            const SizedBox(
              height: 12.0,
            ),
            Text(barcode),
            const SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SmoothSimpleButton(
                  context: context,
                  text: 'Add',
                  width: 100.0,
                  onPressed: () {
                    Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) =>
                                SmoothUploadPage(barcode: barcode)));
                    callback();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
