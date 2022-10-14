import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/model/LoginStatus.dart';
import 'package:openfoodfacts/model/SignUpStatus.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/QueryType.dart';

void main() {
  const QueryType queryType = QueryType.TEST;
  final String name = _generateRandomString(4);
  final String email = '$name@example.com';
  const String password = 'test_password';

  group('Create User & Login', () {
    test('Create User', () async {
      final SignUpStatus signUpResponse = await OpenFoodAPIClient.register(
        user: User(userId: name, password: password),
        name: name,
        email: email,
        orgName: null,
        queryType: queryType,
        newsletter: false,
      );

      expect(signUpResponse.status, 201);
    });

    test('Login User', () async {
      final LoginStatus? loginResponse = await OpenFoodAPIClient.login2(
        User(userId: name, password: password),
        queryType: queryType,
      );

      expect(loginResponse?.successful, true);
    });

    test('Wrong Credential User Login', () async {
      final LoginStatus? loginResponse = await OpenFoodAPIClient.login2(
        User(userId: name, password: 'somerandomnewpassword'),
        queryType: queryType,
      );
      expect(loginResponse?.successful, false);
    }, skip: '401 code and null response');
    test('Duplicate Registration', () async {
      final SignUpStatus signUpResponse = await OpenFoodAPIClient.register(
        user: User(userId: name, password: password),
        name: name,
        email: email,
        orgName: null,
        queryType: queryType,
        newsletter: false,
      );
      expect(signUpResponse.status, 400);
    });
  });
}

String _generateRandomString(int length) {
  final Random r = Random();
  return String.fromCharCodes(
        List<int>.generate(length, (int index) => r.nextInt(26) + 65),
      ).toLowerCase() +
      (DateTime.now().microsecondsSinceEpoch).toString();
}
