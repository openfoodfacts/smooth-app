import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_template.dart';

class SmoothProductCarousel extends StatelessWidget {
  const SmoothProductCarousel(
      {@required this.productCards, this.controller, this.height = 120.0});

  final Map<String, SmoothProductCardTemplate> productCards;
  final CarouselController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: productCards.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child:
              productCards[productCards.keys.elementAt(index)].build(context),
        );
      },
      carouselController: controller,
      options: CarouselOptions(
        enlargeCenterPage: false,
        viewportFraction: 0.95,
        height: height,
        enableInfiniteScroll: false,
      ),
    );
  }
}
