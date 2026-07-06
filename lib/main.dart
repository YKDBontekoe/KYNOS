import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/app/app.dart';
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';
import 'package:kynos/infrastructure/ai/gemma/gemma_runtime.dart';
import 'package:kynos/infrastructure/ai/secure_api_key_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyStorage = SecureApiKeyStorage();
  final hfToken = await keyStorage.readHuggingFaceToken();
  await GemmaRuntime.initialize(
    huggingFaceToken: hfToken != null && hfToken.isNotEmpty ? hfToken : null,
  );

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const KynosApp(),
    ),
  );
}
