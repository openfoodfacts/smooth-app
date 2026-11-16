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

  final List<String> segments = Uri.parse(
    path,
  ).pathSegments.where((String segment) => segment.isNotEmpty).toList();

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
