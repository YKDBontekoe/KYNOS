import 'package:kynos/core/constants/app_constants.dart';
import 'package:kynos/features/legal/models/legal_document.dart';

/// Static legal copy bundled with the app.
abstract final class LegalDocuments {
  static const privacyPolicy = LegalDocument(
    title: 'Privacy Policy',
    effectiveDate: 'July 6, 2026',
    externalUrl: AppConstants.privacyPolicyUrl,
    sections: [
      LegalSection(
        title: 'Overview',
        body:
            'KYNOS is a privacy-first running coach. We designed the app so your '
            'raw biometric and workout data stays on your device by default. '
            'This policy explains what information the app processes, where it '
            'is stored, and the limited cases in which data may leave your device.',
      ),
      LegalSection(
        title: 'Information We Process',
        body:
            'Depending on how you use KYNOS, the app may process:\n\n'
            '• Workout and route data you import or record (distance, pace, '
            'duration, GPS tracks, heart rate, cadence, and related metrics)\n'
            '• Health platform data you authorize through Apple Health or '
            'Google Health Connect\n'
            '• On-device coaching preferences, model settings, and app configuration\n'
            '• Optional API credentials you enter for model downloads or cloud coaching\n\n'
            'KYNOS does not require an account to use core on-device features.',
      ),
      LegalSection(
        title: 'On-Device Processing',
        body:
            'By default, KYNOS runs its AI coach and biomechanical analysis on your '
            'device. Imported workouts, readiness calculations, and coaching context '
            'are stored locally. When zero-knowledge mode is enabled, raw biometric '
            'data is not transmitted to KYNOS servers.',
      ),
      LegalSection(
        title: 'Optional Cloud Features',
        body:
            'If you choose to enable cloud coaching through OpenRouter, only the '
            'prompt text required to answer your question is sent to the provider '
            'you select. You control whether this feature is enabled and which API '
            'key is used. KYNOS does not sell your health data.',
      ),
      LegalSection(
        title: 'Health Platform Access',
        body:
            'When you grant HealthKit or Health Connect permission, KYNOS reads '
            'only the data needed to power coaching and dashboard insights. You can '
            'revoke access at any time in your device settings or by disconnecting '
            'health permissions inside KYNOS.',
      ),
      LegalSection(
        title: 'Imports and Exports',
        body:
            'Files you import (for example Apple Health export archives or GPX '
            'routes) are parsed on-device and are not uploaded to KYNOS. If you '
            'explicitly export data, the exported file is created locally and shared '
            'only through the destination you choose.',
      ),
      LegalSection(
        title: 'Data Retention and Deletion',
        body:
            'Workout and coaching data remain on your device until you delete it '
            'or uninstall the app. You can clear imported data from Settings. '
            'Secure credentials such as API keys are stored using platform secure '
            'storage where available.',
      ),
      LegalSection(
        title: 'Children',
        body:
            'KYNOS is not directed to children under 13, and we do not knowingly '
            'collect personal information from children.',
      ),
      LegalSection(
        title: 'Changes and Contact',
        body:
            'We may update this policy as the app evolves. Material changes will be '
            'reflected in the effective date above. Questions about privacy can be '
            'sent to privacy@kynos.app.',
      ),
    ],
  );

  static const termsOfService = LegalDocument(
    title: 'Terms of Service',
    effectiveDate: 'July 6, 2026',
    externalUrl: AppConstants.termsOfServiceUrl,
    sections: [
      LegalSection(
        title: 'Agreement',
        body:
            'By installing or using KYNOS, you agree to these Terms of Service. '
            'If you do not agree, do not use the app.',
      ),
      LegalSection(
        title: 'Not Medical Advice',
        body:
            'KYNOS provides fitness coaching and training insights. It is not a '
            'medical device and does not provide medical advice, diagnosis, or '
            'treatment. Consult a qualified professional before starting or changing '
            'a training program, especially if you have a health condition.',
      ),
      LegalSection(
        title: 'Your Responsibilities',
        body:
            'You are responsible for:\n\n'
            '• Using the app safely while running or exercising\n'
            '• Ensuring imported data and device permissions are accurate\n'
            '• Keeping any API keys or tokens you enter secure\n'
            '• Complying with applicable laws and third-party service terms',
      ),
      LegalSection(
        title: 'AI Coaching',
        body:
            'Coaching responses are generated automatically and may be incomplete or '
            'incorrect. You should use your own judgment and verify important '
            'training decisions. On-device and cloud model availability may vary by '
            'device, region, and network conditions.',
      ),
      LegalSection(
        title: 'Third-Party Services',
        body:
            'KYNOS may link to or integrate with third-party services such as '
            'Hugging Face, OpenRouter, Apple Health, or Google Health Connect. '
            'Your use of those services is governed by their own terms and privacy '
            'policies.',
      ),
      LegalSection(
        title: 'Acceptable Use',
        body:
            'You may not misuse KYNOS, attempt to reverse engineer model weights '
            'except as permitted by law, interfere with app security, or use the app '
            'in any unlawful manner.',
      ),
      LegalSection(
        title: 'Disclaimer',
        body:
            'KYNOS is provided "as is" without warranties of any kind, to the '
            'maximum extent permitted by law. We do not guarantee uninterrupted '
            'service, injury prevention, or specific fitness outcomes.',
      ),
      LegalSection(
        title: 'Limitation of Liability',
        body:
            'To the fullest extent permitted by law, KYNOS and its contributors '
            'are not liable for indirect, incidental, special, consequential, or '
            'punitive damages, or for injuries or losses arising from your training '
            'activities or reliance on coaching output.',
      ),
      LegalSection(
        title: 'Changes and Contact',
        body:
            'We may update these terms from time to time. Continued use after an '
            'update constitutes acceptance of the revised terms. Questions can be '
            'sent to legal@kynos.app.',
      ),
    ],
  );
}
