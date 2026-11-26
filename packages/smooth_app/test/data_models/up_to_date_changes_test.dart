import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/data_models/up_to_date_changes.dart';

Map<String, dynamic> _inputSet(String per, Map<String, dynamic> nutrients) =>
    <String, dynamic>{
      'source': 'packaging',
      'preparation': 'as_sold',
      'per': per,
      'nutrients': nutrients,
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
      _inputSet('100g', <String, dynamic>{
        'fat': _gramValue('1'),
        'iron': _gramValue('2'),
      }),
      _inputSet('serving', <String, dynamic>{'fat': _gramValue('3')}),
    ]);

    test('replaces a nutrient and keeps the others', () {
      final Map<String, dynamic> result = UpToDateChanges.mergeNutrition(
        initial,
        _nutrition(<Map<String, dynamic>>[
          _inputSet('100g', <String, dynamic>{'fat': _gramValue('5')}),
        ]),
      );
      expect(_sets(result)[0]['nutrients'], <String, dynamic>{
        'fat': _gramValue('5'),
        'iron': _gramValue('2'),
      });
      expect(_sets(result)[1], _sets(initial)[1]);
    });

    test('keeps a cleared nutrient as cleared', () {
      final Map<String, dynamic> result = UpToDateChanges.mergeNutrition(
        initial,
        _nutrition(<Map<String, dynamic>>[
          _inputSet('serving', <String, dynamic>{'fat': _gramValue('')}),
        ]),
      );
      expect(_sets(result)[1]['nutrients'], <String, dynamic>{
        'fat': _gramValue(''),
      });
    });

    test('appends a new set', () {
      final Map<String, dynamic> result = UpToDateChanges.mergeNutrition(
        initial,
        _nutrition(<Map<String, dynamic>>[
          _inputSet('100ml', <String, dynamic>{
            'fat': _gramValue('4'),
            'iron': _gramValue(''),
          }),
        ]),
      );
      expect(_sets(result), hasLength(3));
      expect(_sets(result)[2]['per'], '100ml');
      expect(_sets(result)[2]['nutrients'], <String, dynamic>{
        'fat': _gramValue('4'),
        'iron': _gramValue(''),
      });
    });

    test('keeps the other keys and does not modify the initial map', () {
      final Map<String, dynamic> result = UpToDateChanges.mergeNutrition(
        initial,
        _nutrition(<Map<String, dynamic>>[
          _inputSet('100g', <String, dynamic>{'fat': _gramValue('5')}),
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
          _inputSet('100g', <String, dynamic>{'fat': _gramValue('5')}),
        ]),
      );
      expect(_sets(result), hasLength(1));
    });
  });
}
