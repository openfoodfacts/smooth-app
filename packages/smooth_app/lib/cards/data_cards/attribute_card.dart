import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/html_page.dart';

class AttributeCard extends StatelessWidget {
  const AttributeCard(
    this.attribute,
    this.attributeChip, {
    this.barcode,
    Key? key,
  }) : super(key: key);

  final Attribute attribute;
  final Widget attributeChip;
  final String? barcode;

  @override
  Widget build(BuildContext context) {
    final String? description =
        attribute.descriptionShort ?? attribute.description;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                attribute.title ?? '',
                style: Theme.of(context).textTheme.headline3,
              ),
              if (description != null)
                Text(
                  description,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              if (attribute.id == Attribute.ATTRIBUTE_ECOSCORE)
                _getEcoscoreAddition(context),
            ],
          ),
        ),
        attributeChip,
      ],
    );
  }

  Widget _getEcoscoreAddition(final BuildContext context) => ElevatedButton(
        onPressed: () async {
          final String languageCode =
              ProductQuery.getCurrentLanguageCode(context);
          final String? detailsHtmlString =
              await _openFoodApiClientGetEcoscoreHtmlDescription(
            barcode!,
            LanguageHelper.fromJson(languageCode),
          );
          if (detailsHtmlString == null) {
            // TODO(monsieurtanuki): display something nice in that case
            return;
          }
          await Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => HtmlPage(
                htmlString: detailsHtmlString,
                pageTitle: attribute.title!,
              ),
            ),
          );
        },
        child: const Text('Details...'),
      );

  // TODO(monsieurtanuki): replace with OpenFoodAPIClient.getEcoscoreHtmlDescription when it's available
  Future<String?> _openFoodApiClientGetEcoscoreHtmlDescription(
    final String barcode,
    final OpenFoodFactsLanguage language,
  ) async {
    try {
      const String FIELD = 'environment_infocard';
      final String ecoscoreDetailsUrl =
          'https://world-${language.code}.openfoodfacts.org/api/v0/product/$barcode.json?fields=$FIELD';
      final http.Response response =
          await http.get(Uri.parse(ecoscoreDetailsUrl));
      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> product =
          json['product'] as Map<String, dynamic>;
      return product[FIELD] as String;
    } catch (e) {
      return null;
    }
  }
}
