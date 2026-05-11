// import 'dart:convert';
//
// import 'package:flutter/services.dart';
//
// import 'app_logger.dart';
// import 'package:googleapis_auth/auth_io.dart';
//
// Future<Map<Object, Object>> getAccessToken() async {
//   AppLogger.i("Generating Google Sheets access token");
//
//   final jsonString = await rootBundle.loadString('assets/service_account.json');
//
//   final credentials = ServiceAccountCredentials.fromJson(
//     json.decode(jsonString),
//   );
//
//   final scopes = ['https://www.googleapis.com/auth/spreadsheets'];
//
//   final client = await clientViaServiceAccount(credentials, scopes);
//
//   AppLogger.s("Access token generated");
//   // return client.credentials.accessToken.data;
//
//     final token = client.credentials.accessToken.data;
//     final expiry = client.credentials.accessToken.expiry;
// return {
//   'token': token,
//   'expiry': expiry
// };
// }