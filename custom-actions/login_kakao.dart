// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;

Future<void> loginKakao() async {
  // 1. 카카오톡 사용 혹은 계정을 이용하여 카카오 로그인
  if (await kakao.isKakaoTalkInstalled()) {
    await kakao.UserApi.instance.loginWithKakaoTalk();
  } else {
    await kakao.UserApi.instance.loginWithKakaoAccount();
  }

  // 2. 카카오 유저 정보로부터 앱에서 사용할 유저 데이터 가공
  final kakaoUser = await kakao.UserApi.instance.me();
  print('### kakaoUser: $kakaoUser');
  final user = {
    'email': kakaoUser.kakaoAccount?.email,
    'displayName': kakaoUser.properties?['nickname'],
    'photoURL': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
    'uid': 'kakao_${kakaoUser.id}',
    'phoneNumber': kakaoUser.kakaoAccount?.phoneNumber,
  };
  print('### user before remove null: $user');
  // null 데이터 제거
  user.removeWhere((key, value) => value == null);
  print('### user: $user');

  // 3. cloud functions 를 이용하여 커스텀 토큰 생성
  HttpsCallable callable =
      FirebaseFunctions.instanceFor(region: 'asia-northeast3')
          .httpsCallable('createCustomToken');
  final response = await callable.call({'user': user});
  print('Custom token: ${response.data['token']}');

  final token = response.data['token'];
  print('### token: $token');

  // 4. 커스텀 토큰으로 로그인 진행
  final credential = await FirebaseAuth.instance.signInWithCustomToken(token);
  print('### userCredential: $credential');

  // 5. DB 에 유저 데이터 동록
  await maybeCreateUser(credential.user!);
}
