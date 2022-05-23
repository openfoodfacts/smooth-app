import 'dart:math' as math;

import 'package:data_importer_shared/data_importer_shared.dart';

class ImportableUser {
  ImportableUser({
    required this.userName,
    required this.password,
  });

  final String userName;
  final String password;

  UserCredentials toUser() => UserCredentials(userName, password);
}

class ImportableUserData {
  ImportableUserData({
    Iterable<String>? history,
    this.lists,
  }) : history = history
            ?.where((String barcode) => barcode.isNotEmpty)
            .toList(growable: false);

  final ImportableProductList? history;
  final ImportableUserLists? lists;

  UserListsData toUserData(int maxHistoryLength) => UserListsData(
      history?.sublist(
          0, history != null ? math.min(history!.length, maxHistoryLength) : 0),
      lists?.map<UserList>(
        (ImportableUserList list) {
          return list.toUserList();
        },
      ).toSet());
}

class ImportableUserList {
  ImportableUserList({
    required this.label,
    required this.products,
  });

  final String label;
  final ImportableProductList products;

  MapEntry<String, dynamic> export() => MapEntry<String, dynamic>(
        label,
        <String, String?>{
          'barcodes': products.join(','),
        },
      );

  UserList toUserList() => UserList(label, products);
}

typedef ImportableUserLists = Set<ImportableUserList>;
typedef ImportableProductList = List<String>;
