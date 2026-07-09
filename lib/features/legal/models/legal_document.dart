/// A section within an in-app legal document.
class LegalSection {
  const LegalSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

/// Bundled legal copy shown inside the app.
class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.effectiveDate,
    required this.sections,
    this.externalUrl,
  });

  final String title;
  final String effectiveDate;
  final List<LegalSection> sections;

  /// Optional public URL for an online version of the same document.
  final String? externalUrl;
}
