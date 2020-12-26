import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';
import 'package:smooth_app/temp/user_preferences.dart';

class UserDatabase {
  UserDatabase() {
    factory = databaseFactoryIo;
  }

  DatabaseFactory factory;

  Future<bool> saveUserPreferences(UserPreferences userPreferences) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, 'user_database.db');
    final Database database = await factory.openDatabase(path);

    try {
      final StoreRef<dynamic, dynamic> store =
          StoreRef<dynamic, dynamic>.main();
      await store
          .record('user_preferences')
          .put(database, userPreferences.toJson());
      return true;
    } catch (e) {
      print(
          'An error occurred while saving user preferences to local database : $e');
      return false;
    }
  }

  Future<UserPreferences> getUserPreferences() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, 'user_database.db');
    final Database database = await factory.openDatabase(path);

    try {
      final StoreRef<dynamic, dynamic> store =
          StoreRef<dynamic, dynamic>.main();
      final Map<String, dynamic> jsonUserPreferences = await store
          .record('user_preferences')
          .get(database) as Map<String, dynamic>;
      return jsonUserPreferences != null
          ? UserPreferences.filled(jsonUserPreferences)
          : UserPreferences();
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
      return null;
    }
  }
}
