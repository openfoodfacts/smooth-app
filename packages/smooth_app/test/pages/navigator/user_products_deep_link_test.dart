import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/pages/navigator/user_products_deep_link.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';

void main() {
  group('userSearchTypeFromDeepLink', () {
    test('/editor/<me> opens the products I edited', () {
      expect(
        userSearchTypeFromDeepLink(
          '/editor/teolemon',
          loggedInUserId: 'teolemon',
        ),
        UserSearchType.INFORMER,
      );
    });

    test('ignores the case of the user id', () {
      expect(
        userSearchTypeFromDeepLink(
          '/editor/TeoLemon',
          loggedInUserId: 'teolemon',
        ),
        UserSearchType.INFORMER,
      );
    });

    test('ignores a trailing slash', () {
      expect(
        userSearchTypeFromDeepLink(
          '/editor/teolemon/',
          loggedInUserId: 'teolemon',
        ),
        UserSearchType.INFORMER,
      );
    });

    test('works for a username that looks like a barcode', () {
      expect(
        userSearchTypeFromDeepLink(
          '/editor/12345678',
          loggedInUserId: '12345678',
        ),
        UserSearchType.INFORMER,
      );
    });

    test('stays on the website for another user', () {
      expect(
        userSearchTypeFromDeepLink(
          '/editor/someone',
          loggedInUserId: 'teolemon',
        ),
        isNull,
      );
    });

    test('stays on the website when nobody is logged in', () {
      expect(
        userSearchTypeFromDeepLink('/editor/teolemon', loggedInUserId: null),
        isNull,
      );
    });

    test('stays on the website for other pages of the user', () {
      expect(
        userSearchTypeFromDeepLink(
          '/editor/teolemon/2',
          loggedInUserId: 'teolemon',
        ),
        isNull,
      );
      expect(
        userSearchTypeFromDeepLink('/editor', loggedInUserId: 'teolemon'),
        isNull,
      );
    });

    test('stays on the website for unknown pages', () {
      expect(
        userSearchTypeFromDeepLink(
          '/product/teolemon',
          loggedInUserId: 'teolemon',
        ),
        isNull,
      );
    });
  });

  group('isUserSearchDeepLink', () {
    test('matches the pages of any user, whatever the page', () {
      expect(isUserSearchDeepLink('/editor/teolemon'), isTrue);
      expect(isUserSearchDeepLink('/editor/teolemon/2'), isTrue);
      expect(isUserSearchDeepLink('/editor/12345678/2'), isTrue);
    });

    test('ignores other paths', () {
      expect(isUserSearchDeepLink('/product/3017620422003'), isFalse);
      expect(isUserSearchDeepLink('/editor'), isFalse);
      expect(isUserSearchDeepLink(''), isFalse);
    });
  });
}
