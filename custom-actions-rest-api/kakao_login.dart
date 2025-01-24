// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future kakaoLogin(
  BuildContext context,
  String clientId,
  String loginRedirectUri,
) async {
  String? code = await _tryLogin(context, clientId, loginRedirectUri);
  if (code == null) return;

  final user = await _getKakaoUserData(
    code,
    clientId,
    loginRedirectUri,
  );

  await _createFirebaseUser(user);
}

Future<String?> _tryLogin(
  BuildContext context,
  String clientId,
  String loginRedirectUri,
) async {
  print('### inappwebview 에서 카카오 로그인 시도');
  final uri = Uri.parse('https://kauth.kakao.com/oauth/authorize').replace(
    queryParameters: {
      'client_id': clientId,
      'redirect_uri': loginRedirectUri,
      'response_type': 'code'
    },
  ).toString();

  final loginResultUri = await context.pushNamed(
    'WebViewPage',
    queryParameters: {
      'uri': serializeParam(
        uri,
        ParamType.String,
      ),
      'redirectUri': serializeParam(
        loginRedirectUri,
        ParamType.String,
      ),
    }.withoutNulls,
  );

  final code = Uri.parse(loginResultUri as String).queryParameters['code'];
  return code;
}

Future<dynamic> _getKakaoUserData(
  String code,
  String clientId,
  String loginRedirectUri,
) async {
  final Map session = await _fetchSessionData(code, clientId, loginRedirectUri);
  final Map kakaoUser = await _fetchUserData(session['access_token']);
  print('### kakaoUser: ${jsonEncode(kakaoUser)}');

  final result = {
    'uid': 'kakao_${kakaoUser['id']}',
    'email': kakaoUser['kakao_account']?['email'],
    'displayName': kakaoUser['properties']?['nickname'],
    'photoURL': kakaoUser['kakao_account']?['profile']?['profile_image_url'],
    'phoneNumber': kakaoUser['kakao_account']?['phone_number'],
  };

  print('### null 제거 전: $result');
  result.removeWhere((key, value) => value == null);
  print('### null 제거 후: $result');

  return result;
}

Future<dynamic> _fetchSessionData(
    String code, String clientId, String loginRedirectUri) async {
  print('### kakao session data 가져오기');
  final response = await http.post(
    Uri.parse('https://kauth.kakao.com/oauth/token'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
    },
    body: {
      'grant_type': 'authorization_code',
      'client_id': clientId,
      'redirect_uri': loginRedirectUri,
      'code': code,
    },
  );

  print('### sessionData: ${response.body}');

  final result = jsonDecode(response.body);
  return result!;
}

Future<dynamic> _fetchUserData(String accessToken) async {
  print('### kakao user data 가져오기');
  final response = await http.get(
    Uri.parse('https://kapi.kakao.com/v2/user/me'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
    },
  );
  print('### kakao user data: ${response.body}');

  return jsonDecode(response.body);
}

Future<void> _createFirebaseUser(dynamic user) async {
  print('### cloud functions "createCustomToken" 호출');
  HttpsCallable callable =
      FirebaseFunctions.instanceFor(region: 'asia-northeast3')
          .httpsCallable('createCustomToken');
  final response = await callable.call({'user': user});
  print('### createCustomToken result: ${response.data}');

  final token = response.data['token'];

  print('### 커스텀 토큰으로 로그인 진행');
  final credential = await FirebaseAuth.instance.signInWithCustomToken(token);
  print('### firebase userCredential: $credential');

  print('### ff 사용자 생성');
  return await maybeCreateUser(credential.user!);
}
