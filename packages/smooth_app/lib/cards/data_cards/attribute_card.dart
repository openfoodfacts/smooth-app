import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/html_page.dart';

class AttributeCard extends StatelessWidget {
  const AttributeCard(
    this.attribute,
    this.attributeChip, {
    this.barcode,
  });

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
          final String language = ProductQuery.getCurrentLanguageCode(context);
          const String FIELD = 'environment_infocard';
          final String ecoscoreDetailsUrl =
              'https://world-$language.openfoodfacts.org/api/v0/product/$barcode.json?fields=$FIELD';
          http.Response response;
          response = await http.get(Uri.parse(ecoscoreDetailsUrl));
          if (response.statusCode != 200) {
            return; // TODO(monsieurtanuki): display something nice in that case
          }
          // TODO(monsieurtanuki): check if the json is correct and successful
          final Map<String, dynamic> json =
              jsonDecode(response.body) as Map<String, dynamic>;
          final Map<String, dynamic> product =
              json['product'] as Map<String, dynamic>;
          final String detailsHtmlString = product[FIELD] as String;
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
}
