import 'dart:async';

import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_browser.dart' as browser;

browser.Authenticator? _authenticator;

Future<Credential> authenticate(Client client,
    {List<String> scopes = const []}) async {
  _authenticator ??= browser.Authenticator(client, scopes: scopes);
  _authenticator!.authorize();
  return Completer<Credential>().future;
}

Future<Credential?> getRedirectResult(Client client,
    {List<String> scopes = const []}) async {
  _authenticator ??= browser.Authenticator(client, scopes: scopes);
  return await _authenticator!.credential;
}

Future<void> logout() async {
  await _authenticator?.logout();
  _authenticator = null;
}
