import 'dart:io';
import 'package:flutter/foundation.dart';
import 'constants.dart';
import 'environment.dart';

class ApiConfig {
  static String get baseUrl {
    if (Environment.isProduction) {
      // Producción
      return AppConstants.prodBaseUrl;
    } else {
      // Desarrollo
      if (kIsWeb) return AppConstants.webLocalBaseUrl;
      if (Platform.isAndroid) return AppConstants.localBaseUrl;
      if (Platform.isIOS) return AppConstants.localBaseUrlIOS;
      return AppConstants.localBaseUrl;
    }
  }
}
