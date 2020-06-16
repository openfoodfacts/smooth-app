
import 'package:flutter/material.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_template.dart';

class SmoothProductCardNotFound extends SmoothProductCardTemplate {
  SmoothProductCardNotFound({@required this.barcode});

  final String barcode;

  @override
  Widget build() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: const Center(
        child: Text('Product not found'),
      ),
    );
  }
}