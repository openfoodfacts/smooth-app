import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/dao_secured_string.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Keycloak (OIDC) authentication for ProductOpener write/read calls.
///
/// Smooth-app is a public client (no backend, no secret): it uses the
/// Authorization Code flow with PKCE in the system browser, per RFC 8252.
/// See https://github.com/openfoodfacts/openfoodfacts-auth
///
/// The access token is injected into every `OpenFoodAPIClient` ProductOpener
/// request through [OpenFoodAPIConfiguration.bearerTokenProvider], which the
/// dart package resolves (explicit `bearerToken` > `globalBearerToken` >
/// provider). Password-based auth keeps working as a fallback while the
/// Keycloak client is being rolled out.
class KeycloakAuthService {
  KeycloakAuthService._();

  static final KeycloakAuthService instance = KeycloakAuthService._();

  /// Keycloak realm issuer. No client is pre-configured in production yet;
  /// `clientId` below must be registered as a public client (standard flow,
  /// PKCE) on this realm before interactive login can work.
  static const String issuer =
      'https://auth.openfoodfacts.org/realms/openfoodfacts';

  static const String discoveryUrl =
      '$issuer/.well-known/openid-configuration';

  // TODO(off): register `smooth-app` as a public Keycloak client (standard
  // flow + PKCE, valid redirect `redirectUrl`) and replace if named
  // differently.
  static const String clientId = 'smooth-app';

  /// Custom scheme redirect; must match the Keycloak client's valid
  /// redirect URIs and the Android `appAuthRedirectScheme` placeholder.
  static const String redirectUrl = 'org.openfoodfacts.app://oauth/callback';

  /// `offline_access` yields a refresh token; `products:*` are the
  /// ProductOpener scopes (openfoodfacts-auth#462).
  static const List<String> scopes = <String>[
    'openid',
    'profile',
    'email',
    'offline_access',
    'products:read',
    'products:write',
  ];

  static const String _accessTokenKey = 'keycloak_access_token';
  static const String _refreshTokenKey = 'keycloak_refresh_token';
  static const String _expiryKey = 'keycloak_access_token_expiry_ms';
  static const String _idTokenKey = 'keycloak_id_token';

  /// Refresh a minute before actual expiry (clock skew + latency).
  static const Duration _expiryTolerance = Duration(minutes: 1);

  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  bool _wired = false;

  /// Registers the token provider; call once at startup (see `main.dart`).
  void wireAsBearerProvider() {
    if (_wired) {
      return;
    }
    OpenFoodAPIConfiguration.bearerTokenProvider = getValidAccessToken;
    _wired = true;
  }

  /// Returns a usable access token, refreshing it when needed.
  ///
  /// Returns null when logged out or when refresh fails (callers then fall
  /// back to password auth or anonymous, per the dart package behavior).
  Future<String?> getValidAccessToken() async {
    try {
      final String? accessToken = await DaoSecuredString.get(_accessTokenKey);
      final String? expiryMs = await DaoSecuredString.get(_expiryKey);
      if (accessToken != null && expiryMs != null) {
        final DateTime? expiry = DateTime.tryParse(expiryMs);
        if (expiry != null &&
            DateTime.now().isBefore(expiry.subtract(_expiryTolerance))) {
          return accessToken;
        }
      }
      final String? refreshToken =
          await DaoSecuredString.get(_refreshTokenKey);
      if (refreshToken == null) {
        return accessToken;
      }
      final TokenResponse response = await _appAuth.token(
        TokenRequest(
          clientId,
          redirectUrl,
          discoveryUrl: discoveryUrl,
          refreshToken: refreshToken,
          scopes: scopes,
        ),
      );
      if (response.accessToken != null) {
        await _persist(response);
        return response.accessToken;
      }
      return accessToken;
    } catch (e) {
      Logs.e('Keycloak token refresh failed', ex: e);
      return null;
    }
  }

  /// Whether tokens for a Keycloak session are stored locally.
  Future<bool> isLoggedIn() async =>
      await DaoSecuredString.get(_refreshTokenKey) != null ||
      await DaoSecuredString.get(_accessTokenKey) != null;

  /// Interactive login in the system browser. Returns true on success.
  ///
  /// Throws [FlutterAppAuthUserCancelledException] when the user cancels;
  /// callers should treat that as a graceful abort, not an error.
  Future<bool> login() async {
    final AuthorizationTokenResponse result =
        await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        scopes: scopes,
      ),
    );
    if (result.accessToken == null) {
      return false;
    }
    await _persist(result);
    return true;
  }

  /// Logs out locally and, when possible, at Keycloak (RP-initiated logout).
  Future<void> logout() async {
    final String? idToken = await DaoSecuredString.get(_idTokenKey);
    try {
      await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: redirectUrl,
          discoveryUrl: discoveryUrl,
        ),
      );
    } catch (e) {
      // Best effort: still clear local tokens below.
      Logs.e('Keycloak end session failed', ex: e);
    }
    await DaoSecuredString.remove(key: _accessTokenKey);
    await DaoSecuredString.remove(key: _refreshTokenKey);
    await DaoSecuredString.remove(key: _expiryKey);
    await DaoSecuredString.remove(key: _idTokenKey);
  }

  Future<void> _persist(TokenResponse response) async {
    if (response.accessToken != null) {
      await DaoSecuredString.put(
        key: _accessTokenKey,
        value: response.accessToken!,
      );
    }
    // Refresh tokens rotate: always replace the stored one.
    if (response.refreshToken != null) {
      await DaoSecuredString.put(
        key: _refreshTokenKey,
        value: response.refreshToken!,
      );
    }
    if (response.accessTokenExpirationDateTime != null) {
      await DaoSecuredString.put(
        key: _expiryKey,
        value: response.accessTokenExpirationDateTime!.toIso8601String(),
      );
    }
    if (response.idToken != null) {
      await DaoSecuredString.put(key: _idTokenKey, value: response.idToken!);
    }
  }
}
