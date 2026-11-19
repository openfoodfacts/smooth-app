import 'package:smooth_app/query/paged_user_product_query.dart';

/// The website pages listing the products of a user, and their app counterpart.
/// Eg: `https://world.openfoodfacts.org/editor/teolemon`
const Map<String, UserSearchType> _USER_SEARCH_PATHS = <String, UserSearchType>{
  'editor': UserSearchType.INFORMER,
};

/// Returns the [UserSearchType] matching a deep link to the products of the
/// logged in user (eg: `/editor/<userId>`).
///
/// Returns null if [path] isn't such a link, if nobody is logged in or if it
/// targets another user: those links stay on the website.
UserSearchType? userSearchTypeFromDeepLink(
  String path, {
  required String? loggedInUserId,
}) {
  if (loggedInUserId == null) {
    return null;
  }

  final List<String> segments = _pathSegments(path);

  if (segments.length != 2) {
    return null;
  }

  final UserSearchType? type = _USER_SEARCH_PATHS[segments.first];
  if (type == null ||
      segments.last.toLowerCase() != loggedInUserId.toLowerCase()) {
    return null;
  }

  return type;
}

/// Whether [path] belongs to the website pages listing the products of a user
/// (eg: `/editor/<userId>/2`), whoever the user is.
///
/// Such a path never targets a product, even when its user id looks like a
/// barcode.
bool isUserSearchDeepLink(String path) {
  final List<String> segments = _pathSegments(path);

  return segments.length > 1 && _USER_SEARCH_PATHS.containsKey(segments.first);
}

/// Splits without decoding: decoding throws on malformed escapes (eg: `%E9`),
/// which must not break the routing of unrelated links such as products.
List<String> _pathSegments(String path) =>
    path.split('/').where((String segment) => segment.isNotEmpty).toList();
