import 'dart:io';

import 'package:flutter_iptv/app.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  runApp(const App());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) =>
          true;
  }
}
