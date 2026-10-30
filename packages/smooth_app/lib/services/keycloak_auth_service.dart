import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_secured_string.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Thrown when a stored Keycloak session is definitively dead.
///
/// Unlike a missing session (never logged in → provider returns null and the
/// dart package falls back to password/anonymous auth), a dead session must
/// be loud: callers quarantine the failing work instead of retrying it
/// silently (see `BackgroundTaskManager` auth-blocked tasks).
class KeycloakSessionExpiredException implements Exception {
  const KeycloakSessionExpiredException([this.details]);

  final Object? details;

  @override
  String toString() =>
      'KeycloakSessionExpiredException${details == null ? '' : ' ($details)'}';
}

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

  /// Keycloak realm issuer, following the ProductOpener environment.
  ///
  /// PROD app builds talk to `openfoodfacts.org` and authenticate against
  /// `auth.openfoodfacts.org`; TEST builds (`openfoodfacts.net`, including a
  /// custom test-env domain) use `auth.openfoodfacts.net`. No Keycloak client
  /// is pre-configured in production yet; `clientId` below must be registered
  /// as a public client (standard flow, PKCE) on both realms before
  /// interactive login can work.
  static const String _prodDomain = 'openfoodfacts.org';
  static const String _testDomain = 'openfoodfacts.net';
  static const String _realm = 'openfoodfacts';

  /// Whether ProductOpener requests currently target production.
  ///
  /// Synced from the dev-mode PROD/TEST switch via [syncEnvironment].
  bool _useProd = true;

  /// Custom issuer override for TEST builds (dev-mode option).
  ///
  /// Lets a custom test environment point at its own Keycloak instance
  /// (e.g. a local `http://auth.openfoodfacts.localhost:5600`
  /// from openfoodfacts-auth `make up`). Ignored for PROD builds.
  String? _customIssuer;

  String get issuer {
    if (_useProd) {
      return 'https://auth.$_prodDomain/realms/$_realm';
    }
    final String? custom = _customIssuer;
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }
    return 'https://auth.$_testDomain/realms/$_realm';
  }

  String get discoveryUrl => '$issuer/.well-known/openid-configuration';

  /// Points the service at the current ProductOpener environment.
  ///
  /// Call at startup and whenever the dev-mode PROD/TEST switch (or the
  /// custom issuer) changes. Returns true when the effective environment
  /// changed (never on the first call): the old scope's tokens are purged
  /// first, as they won't work against the other environment's
  /// ProductOpener instance. Callers should also drop a Keycloak-managed
  /// app user on change (see `UserManagementProvider`).
  /// A custom issuer additionally namespaces its own token set.
  Future<bool> syncEnvironment(final UserPreferences userPreferences) async {
    final bool newUseProd =
        userPreferences.getFlag(
          UserPreferencesDevMode.userPreferencesFlagProd,
        ) ??
        true;
    final String? newCustomIssuer = _normalizeIssuer(
      userPreferences.getDevModeString(
        UserPreferencesDevMode.userPreferencesKeycloakIssuer,
      ),
    );
    if (!_initialized) {
      _useProd = newUseProd;
      _customIssuer = newCustomIssuer;
      _initialized = true;
      return false;
    }
    if (newUseProd == _useProd && newCustomIssuer == _customIssuer) {
      return false;
    }
    await _purgeScope(_scopeFor(_useProd, _customIssuer));
    _useProd = newUseProd;
    _customIssuer = newCustomIssuer;
    return true;
  }

  /// Normalizes a user-entered issuer: trims, drops trailing slashes, and
  /// defaults to https (local `http://…` issuers work for Android dev builds).
  static String? _normalizeIssuer(final String? value) {
    final String trimmed = (value ?? '').trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.contains('://') ? trimmed : 'https://$trimmed';
  }

  // TODO(off): register `smooth-app` as a public Keycloak client (standard
  // flow + PKCE, valid redirect `redirectUrl`) on both realms, keeping the
  // client id in sync, and replace if named differently.
  static const String clientId = 'smooth-app';

  /// Custom scheme redirect; must match the Keycloak client's valid
  /// redirect URIs and the Android `appAuthRedirectScheme` placeholder.
  static const String redirectUrl = 'org.openfoodfacts.app://oauth/callback';

  /// Marker stored in [User.comment] for Keycloak-managed app users.
  ///
  /// The app keys "signed in" off `OpenFoodAPIConfiguration.globalUser`, so a
  /// successful Keycloak login installs a marker [User] carrying the Keycloak
  /// username and an empty password. Bearer tokens take precedence on every
  /// request, so the empty password is never used while the session is alive.
  static const String managedUserMarker = 'keycloak-sso';

  /// `offline_access` yields a refresh token; `products:*` are the
  /// ProductOpener scopes (openfoodfacts-auth#462).
  static const List<String> scopes = <String>[
    'openid',
    'profile',
    'email',
    'offline_access',
  ];

  static const String _accessTokenSuffix = 'access_token';
  static const String _refreshTokenSuffix = 'refresh_token';
  static const String _expirySuffix = 'access_token_expiry_ms';
  static const String _idTokenSuffix = 'id_token';

  /// Storage keys are namespaced per environment (prod vs test issuer).
  String get _accessTokenKey => _key(_accessTokenSuffix);
  String get _refreshTokenKey => _key(_refreshTokenSuffix);
  String get _expiryKey => _key(_expirySuffix);
  String get _idTokenKey => _key(_idTokenSuffix);

  String _key(final String suffix) => 'keycloak_${_scope}_$suffix';

  /// Token namespace: prod, test, or the sanitized custom issuer.
  String get _scope => _scopeFor(_useProd, _customIssuer);

  static String _scopeFor(final bool useProd, final String? customIssuer) {
    if (useProd) {
      return 'prod';
    }
    if (customIssuer == null) {
      return 'test';
    }
    String scope =
        'custom_${customIssuer.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    if (scope.length > 64) {
      scope = scope.substring(scope.length - 64);
    }
    return scope;
  }

  bool _initialized = false;

  /// Deletes all stored tokens of the given namespace scope.
  Future<void> _purgeScope(final String scope) async {
    for (final String suffix in <String>[
      _accessTokenSuffix,
      _refreshTokenSuffix,
      _expirySuffix,
      _idTokenSuffix,
    ]) {
      await DaoSecuredString.remove(key: 'keycloak_${scope}_$suffix');
    }
  }

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

  /// Whether Keycloak tokens are stored locally (logged in at some point).
  ///
  /// Says nothing about validity; use [validateSession] for that.
  Future<bool> hasStoredSession() async =>
      await DaoSecuredString.get(_refreshTokenKey) != null ||
      await DaoSecuredString.get(_accessTokenKey) != null;

  /// Checks the stored session and purges it when definitively dead.
  ///
  /// Returns true when a usable token exists (refreshing if needed),
  /// false when logged out or the session was purged. Transient (e.g.
  /// network) failures rethrow so callers can retry later.
  Future<bool> validateSession() async {
    if (!await hasStoredSession()) {
      return false;
    }
    try {
      return await getValidAccessToken() != null;
    } on KeycloakSessionExpiredException {
      // Purged inside getValidAccessToken.
      return false;
    }
  }

  /// Returns a usable access token, refreshing it when needed.
  ///
  /// Returns null when never logged in via Keycloak (callers fall back to
  /// password/anonymous auth). Throws [KeycloakSessionExpiredException]
  /// when a stored session is definitively dead (the stored tokens are
  /// purged first) so the failure is loud instead of silently downgrading.
  /// Transient errors (e.g. no network) propagate unchanged for retry.
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
      } else if (accessToken != null) {
        // No recorded expiry (shouldn't happen): use once, refresh next time.
        return accessToken;
      }
      final String? refreshToken = await DaoSecuredString.get(_refreshTokenKey);
      if (refreshToken == null) {
        // Never logged in, or already purged: quiet fallback.
        return null;
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
      if (response.accessToken == null) {
        await purgeTokens();
        throw const KeycloakSessionExpiredException('empty refresh response');
      }
      await _persist(response);
      return response.accessToken;
    } on FlutterAppAuthPlatformException catch (e) {
      if (e.platformErrorDetails.error ==
          FlutterAppAuthOAuthError.invalidGrant) {
        // Refresh token rejected: session is over (logout, expiry, password
        // change, …). Purge so we never present it again.
        await purgeTokens();
        throw KeycloakSessionExpiredException(e.platformErrorDetails);
      }
      rethrow;
    }
  }

  /// Whether tokens for a Keycloak session are stored locally.
  Future<bool> isLoggedIn() => hasStoredSession();

  /// Display username from the stored ID token (display only, unverified).
  ///
  /// Returns null when logged out. Prefers `preferred_username`, then
  /// `name`, `email`, and finally the subject.
  Future<String?> getUsername() async {
    final String? idToken = await DaoSecuredString.get(_idTokenKey);
    if (idToken == null) {
      return null;
    }
    try {
      final List<String> parts = idToken.split('.');
      if (parts.length != 3) {
        return null;
      }
      final Map<String, dynamic> payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      final dynamic name =
          payload['preferred_username'] ??
          payload['name'] ??
          payload['email'] ??
          payload['sub'];
      return name?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Interactive login in the system browser. Returns true on success.
  ///
  /// Throws [FlutterAppAuthUserCancelledException] when the user cancels;
  /// callers should treat that as a graceful abort, not an error.
  Future<bool> login() async {
    final AuthorizationTokenResponse result = await _appAuth
        .authorizeAndExchangeCode(
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
    await purgeTokens();
  }

  /// Deletes all stored tokens of the current scope.
  Future<void> purgeTokens() => _purgeScope(_scope);

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
