import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kynos/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait while the full layout is being built.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const KynosApp());
}
