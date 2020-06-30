import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_template.dart';

class SmoothProductCarousel extends StatelessWidget {
  const SmoothProductCarousel({@required this.productCards, this.controller});

  final Map<String, SmoothProductCardTemplate> productCards;
  final CarouselController controller;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: productCards.length,
      itemBuilder: (BuildContext context, int index) {
        return productCards[productCards.keys.elementAt(index)].build(context);
      },
      carouselController: controller,
      options: CarouselOptions(
        enlargeCenterPage: true,
        viewportFraction: 4 / 5,
        enableInfiniteScroll: false,
      ),
    );
  }
}
