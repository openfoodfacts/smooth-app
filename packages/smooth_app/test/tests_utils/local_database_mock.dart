import 'package:mockito/mockito.dart';
import 'package:smooth_app/data_models/up_to_date_product_list_provider.dart';
import 'package:smooth_app/database/local_database.dart';

class MockLocalDatabase extends Mock implements LocalDatabase {
  final Map<String, int?> _daoInt = <String, int?>{};

  late final UpToDateProductListProvider _upToDateProductList =
      UpToDateProductListProvider(this);

  /// Needed by pages using `UpToDateProductListMixin`, e.g. the history page.
  @override
  UpToDateProductListProvider get upToDateProductList => _upToDateProductList;

  @override
  List<String> getAllTaskIds(final String key) => <String>[];

  @override
  int? daoIntGet(final String key) => _daoInt[key];

  @override
  Future<void> daoIntPut(final String key, final int? value) async =>
      _daoInt[key] = value;
}
