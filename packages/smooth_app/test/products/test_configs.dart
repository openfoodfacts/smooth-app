import 'package:openfoodfacts/model/User.dart';

class TestConfigs {
  static const User TEST_USER = User(
    userId: 'openfoodfacts-dart',
    password: 'iloveflutter',
    comment: 'dart API test',
  );
}

User anonymousUser() {
  return User(
    userId: (DateTime.now().microsecondsSinceEpoch).toString(),
    password: 'some_test-password',
    comment: 'Anonymous User',
  );
}
