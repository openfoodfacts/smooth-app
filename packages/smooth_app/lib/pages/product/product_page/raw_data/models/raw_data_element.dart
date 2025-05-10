sealed class ProductRawDataSubCategory {}

class ProductRawDataElement extends ProductRawDataSubCategory {
  ProductRawDataElement(this.name);

  final String name;
}

class ProductRawDataElementDoubleText extends ProductRawDataSubCategory {
  ProductRawDataElementDoubleText(this.text1, this.text2);

  final String text1;
  final String text2;
}

class ProductRawDataSeeMoreButton extends ProductRawDataSubCategory {}
