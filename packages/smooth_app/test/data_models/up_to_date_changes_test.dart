import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';

Map<String, dynamic> _set(
  String per,
  Map<String, dynamic> nutrients, {
  List<String>? unspecified,
}) => <String, dynamic>{
  'source': 'packaging',
  'preparation': 'as_sold',
  'per': per,
  'nutrients': nutrients,
  'unspecified_nutrients': ?unspecified,
};

Map<String, dynamic> _nutrition(List<Map<String, dynamic>> sets) =>
    <String, dynamic>{
      'aggregated_set': <String, dynamic>{'per': '100g'},
      'input_sets': sets,
    };

Map<String, dynamic> _gramValue(String valueString) => <String, dynamic>{
  'unit': 'g',
  'value_string': valueString,
};

List<Map<String, dynamic>> _sets(Map<String, dynamic> nutrition) =>
    (nutrition['input_sets'] as List<dynamic>).cast<Map<String, dynamic>>();

void main() {
  group('UpToDateChanges.mergeNutrition', () {
    final Map<String, dynamic> initial = _nutrition(<Map<String, dynamic>>[
      _set('100g', <String, dynamic>{
        'fat': _gramValue('1'),
        'iron': _gramValue('2'),
      }),
      _set('serving', <String, dynamic>{'fat': _gramValue('3')}),
    ]);

    test('replaces a nutrient and keeps the others', () {
      final Map<String, dynamic> result = UpToDateChanges.mergeNutrition(
        initial,
        _nutrition(<Map<String, dynamic>>[
          _set('100g', <String, dynamic>{'fat': _gramValue('5')}),
        ]),
      );
      expect(_sets(result)[0]['nutrients'], <String, dynamic>{
        'fat': _gramValue('5'),
        'iron': _gramValue('2'),
      });
      expect(_sets(result)[1], _sets(initial)[1]);
    });

    test('removes a cleared nutrient', () {
      final Map<String, dynamic> result = UpToDateChanges.mergeNutrition(
        initial,
        _nutrition(<Map<String, dynamic>>[
          _set('serving', <String, dynamic>{'fat': _gramValue('')}),
        ]),
      );
      expect(_sets(result)[1]['nutrients'], isEmpty);
    });

    test('appends a new set without its cleared nutrients', () {
      final Map<String, dynamic> result = UpToDateChanges.mergeNutrition(
        initial,
        _nutrition(<Map<String, dynamic>>[
          _set('100ml', <String, dynamic>{
            'fat': _gramValue('4'),
            'iron': _gramValue(''),
          }),
        ]),
      );
      expect(_sets(result), hasLength(3));
      expect(_sets(result)[2]['per'], '100ml');
      expect(_sets(result)[2]['nutrients'], <String, dynamic>{
        'fat': _gramValue('4'),
      });
    });

    test('replaces the unspecified nutrients only when sent', () {
      final Map<String, dynamic> withUnspecified = _nutrition(
        <Map<String, dynamic>>[
          _set(
            '100g',
            <String, dynamic>{'fat': _gramValue('1')},
            unspecified: <String>['salt'],
          ),
        ],
      );
      final Map<String, dynamic> kept = UpToDateChanges.mergeNutrition(
        withUnspecified,
        _nutrition(<Map<String, dynamic>>[
          _set('100g', <String, dynamic>{'fat': _gramValue('2')}),
        ]),
      );
      expect(_sets(kept)[0]['unspecified_nutrients'], <String>['salt']);
      final Map<String, dynamic> replaced = UpToDateChanges.mergeNutrition(
        withUnspecified,
        _nutrition(<Map<String, dynamic>>[
          _set('100g', <String, dynamic>{
            'fat': _gramValue('2'),
          }, unspecified: <String>[]),
        ]),
      );
      expect(_sets(replaced)[0]['unspecified_nutrients'], isEmpty);
    });

    test('keeps the other keys and does not modify the initial map', () {
      final Map<String, dynamic> result = UpToDateChanges.mergeNutrition(
        initial,
        _nutrition(<Map<String, dynamic>>[
          _set('100g', <String, dynamic>{'fat': _gramValue('5')}),
        ]),
      );
      expect(result['aggregated_set'], initial['aggregated_set']);
      expect(
        (_sets(initial)[0]['nutrients'] as Map<String, dynamic>)['fat'],
        _gramValue('1'),
      );
    });

    test('works without initial nutrition', () {
      final Map<String, dynamic> result = UpToDateChanges.mergeNutrition(
        null,
        _nutrition(<Map<String, dynamic>>[
          _set('100g', <String, dynamic>{'fat': _gramValue('5')}),
        ]),
      );
      expect(_sets(result), hasLength(1));
    });
  });
}
