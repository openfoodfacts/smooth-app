import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';

Color getBackgroundColor(final Attribute attribute) {
  if (attribute.status != Attribute.STATUS_KNOWN || attribute.match == null) {
    return const Color.fromARGB(0xff, 0xEE, 0xEE, 0xEE);
  }
  if (attribute.match! <= 20) {
    return const HSLColor.fromAHSL(1, 0, 1, .9).toColor();
  }
  if (attribute.match! <= 40) {
    return const HSLColor.fromAHSL(1, 30, 1, .9).toColor();
  }
  if (attribute.match! <= 60) {
    return const HSLColor.fromAHSL(1, 60, 1, .9).toColor();
  }
  if (attribute.match! <= 80) {
    return const HSLColor.fromAHSL(1, 90, 1, .9).toColor();
  }
  return const HSLColor.fromAHSL(1, 120, 1, .9).toColor();
}

Color getTextColor(final Attribute attribute) {
  if (attribute.status == Attribute.STATUS_KNOWN && attribute.match != null) {
    if (attribute.match! <= 20) {
      return const Color.fromARGB(1, 235, 87, 87);
    }
    if (attribute.match! <= 40) {
      return const Color.fromARGB(1, 242, 153, 74);
    }
    if (attribute.match! <= 60) {
      return const Color.fromARGB(255, 149, 116, 0);
    }
    if (attribute.match! <= 80) {
      return const Color.fromARGB(1, 133, 187, 47);
    }
    return const Color.fromARGB(1, 3, 129, 65);
  } else {
    return const Color.fromARGB(1, 75, 75, 75);
  }
}

Widget getAttributeDisplayIcon(final Attribute attribute) {
  if (attribute.status != Attribute.STATUS_KNOWN || attribute.match == null) {
    // Default emoji.
    return const Text('ℹ️  ');
  }
  if (attribute.match! < 20) {
    return const Text('💔  ');
  }
  if (attribute.match! < 40) {
    return const Text('🍂  ');
  }
  if (attribute.match! < 60) {
    return const Text('🌻  ');
  }
  if (attribute.match! < 80) {
    return const Text('🌱  ');
  }
  return const Text('💚  ');
}

String? getDisplayTitle(final Attribute attribute) {
  if (attribute.id != Attribute.ATTRIBUTE_NOVA) {
    return attribute.title;
  }
  return _getNovaDisplayTitle(attribute);
}

String? _getNovaDisplayTitle(final Attribute attribute) {
  // Note: This method is temporary, this field will come from Backend and it will be internationalized.
  if (attribute.status != Attribute.STATUS_KNOWN ||
      attribute.match == null ||
      attribute.title == null) {
    return null;
  }
  if (attribute.match! <= 20) {
    return 'Ultra processed';
  }
  if (attribute.match! <= 40) {
    return 'Highly processed';
  }
  if (attribute.match! <= 60) {
    return 'Processed';
  }
  if (attribute.match! <= 80) {
    return 'Slightly processed';
  }
  return 'Unprocessed';
}
