// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:firebase_auth/firebase_auth.dart';

Future kakaoLogout(
  BuildContext context,
  String clientId,
  String logoutRedirectUri,
  String uid,
) async {
  dynamic logoutResultUri = await _tryLogout(
    context,
    clientId,
    logoutRedirectUri,
    uid,
  );

  print('### 받은 결과: $logoutRedirectUri');

  if (logoutResultUri == null) {
    print('failed to logout kakao');
    return;
  }

  final state = Uri.parse(logoutResultUri as String).queryParameters['state'];
  print('### 받은 state: $state');

  print('### ff가 상태를 갱신하는 동안 기다려준다.');
  await Future.delayed(Duration(seconds: 1));

  print('### 로그아웃');
  await FirebaseAuth.instance.signOut();
}

Future<dynamic> _tryLogout(
  BuildContext context,
  String clientId,
  String logoutRedirectUri,
  String state,
) async {
  print('### 웹뷰를 통해 카카오 로그아웃 실시');

  final uri = Uri.parse('https://kauth.kakao.com/oauth/logout')
      .replace(queryParameters: {
    'client_id': clientId,
    'logout_redirect_uri': logoutRedirectUri,
    'state': state,
  }).toString();

  print('### 로그아웃 uri: $uri');

  final logoutResultUri = await context.pushNamed(
    'WebViewPage',
    queryParameters: {
      'uri': serializeParam(
        uri,
        ParamType.String,
      ),
      'redirectUri': serializeParam(
        logoutRedirectUri,
        ParamType.String,
      ),
    }.withoutNulls,
  );
  return logoutResultUri;
}
