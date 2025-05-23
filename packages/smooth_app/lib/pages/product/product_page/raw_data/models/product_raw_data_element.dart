sealed class ProductRawDataElement {}

class ProductRawDataElementSimple extends ProductRawDataElement {
  ProductRawDataElementSimple(this.name);

  final String name;
}

class ProductRawDataElementDoubleText extends ProductRawDataElement {
  ProductRawDataElementDoubleText(this.text1, this.text2);

  final String text1;
  final String text2;
}

class ProductRawDataSeeMoreButton extends ProductRawDataElement {}
