import 'package:mockito/mockito.dart';
import 'package:smooth_app/database/local_database.dart';

class MockLocalDatabase extends Mock implements LocalDatabase {
  final Map<String, int?> _daoInt = <String, int?>{};

  @override
  List<String> getAllTaskIds(String key) => <String>[];

  @override
  int? daoIntGet(String key) => _daoInt[key];

  @override
  Future<void> daoIntPut(String key, int? value) async => _daoInt[key] = value;
}
