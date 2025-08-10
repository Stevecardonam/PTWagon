import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

const String _prodApiBaseUrl = 'https://task-api-mfcr.onrender.com';

const String _localIpAndroid = 'http://10.0.2.2:3000';
const String _localIpIos = 'http://localhost:3000';
const String _localIpWeb = 'http://localhost:3000';

String getApiBaseUrl() {
  const isProduction = bool.fromEnvironment('dart.vm.product');
  if (isProduction) {
    return _prodApiBaseUrl;
  }
  
  if (kIsWeb) {
    return _localIpWeb;
  }
  if (Platform.isAndroid) {
    return _localIpAndroid;
  }
  if (Platform.isIOS) {
    return _localIpIos;
  }
  return _localIpWeb;
}

final String apiBaseUrl = getApiBaseUrl();