import 'package:http/http.dart';
import 'package:smooth_app/database/dao_string.dart';

/// Downloadable String that may be stored (and compared to the previous value).
class DownloadableString {
  DownloadableString(this.uri, {this.dao});

  final Uri uri;
  final DaoString? dao;

  String? _value;

  /// The actual string value.
  String? get value => _value;

  /// Downloads data and stores it locally if possible.
  ///
  /// Returns true if the downloaded string is different
  /// from the previously stored one.
  /// May throw an Exception.
  Future<bool> download() async {
    final Response response = await get(uri);
    if (response.statusCode != 200) {
      throw Exception('status is ${response.statusCode} for $uri');
    }
    _value = response.body;

    if (dao != null) {
      final String key = uri.toString();
      final String? previousString = await dao!.get(key);
      if (_value == previousString) {
        return false;
      }
      await dao!.put(key, _value);
    }
    return true;
  }
}
