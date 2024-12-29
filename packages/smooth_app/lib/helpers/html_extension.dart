import 'package:flutter/widgets.dart';

extension AlignmentDirectionalExtension on AlignmentDirectional {
  String toHTMLTextAlign() {
    if (start == -1.0) {
      return 'start';
    } else if (start == 0.0) {
      return 'center';
    } else if (start == 1.0) {
      return 'end';
    } else {
      return 'match-parent';
    }
  }
}
