/// Support for doing something awesome.
///
/// More dartdocs go here.
library data_importer_shared;

class DataImporter {
  DataImporter({
    required this.importUser,
    required this.importLists,
  });

  final Future<bool> Function(UserCredentials user) importUser;
  final Future<bool> Function(UserListsData data) importLists;
}

class UserCredentials {
  UserCredentials(
    this.userName,
    this.password,
  );

  final String userName;
  final String password;
}

class UserListsData {
  UserListsData(
    this.history,
    this.lists,
  );

  final ProductList? history;
  final UserLists? lists;

  Map<String, dynamic> export() {
    final Map<String, dynamic> userLists = <String, dynamic>{};

    if (lists != null) {
      for (final UserList list in lists!) {
        userLists[list.label] = list.export();
      }
    }

    return <String, dynamic>{
      'history': <String, dynamic>{
        'barcodes': history,
      },
      'user_lists': userLists,
    };
  }
}

class UserList {
  UserList(this.label, this.products);

  final String label;
  final ProductList products;

  Map<String, dynamic> export() => <String, dynamic>{
        'barcodes': products,
      };
}

typedef UserLists = Set<UserList>;
typedef ProductList = List<String>;
