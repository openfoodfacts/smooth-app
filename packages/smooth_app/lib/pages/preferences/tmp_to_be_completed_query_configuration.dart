import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/AbstractQueryConfiguration.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';

// TODO(monsieurtanki): move to off-dart
/// Query Configuration for all to-be-completed products.
class ToBeCompletedQueryConfiguration extends AbstractQueryConfiguration {
  ToBeCompletedQueryConfiguration({
    final OpenFoodFactsLanguage? language,
    final List<OpenFoodFactsLanguage> languages =
        const <OpenFoodFactsLanguage>[],
    final OpenFoodFactsCountry? country,
    final List<ProductField>? fields,
    final int? pageNumber,
    final int? pageSize,
  }) : super(
          language: language,
          languages: languages,
          country: country,
          fields: fields,
          additionalParameters: _convertToParametersList(pageNumber, pageSize),
        );

  static List<Parameter> _convertToParametersList(
    int? page,
    int? pageSize,
  ) {
    final List<Parameter> result = <Parameter>[];
    if (page != null) {
      result.add(PageNumber(page: page));
    }
    if (pageSize != null) {
      result.add(PageSize(size: pageSize));
    }
    return result;
  }

  @override
  String getUriPath() => '/state/to-be-completed.json';
}
