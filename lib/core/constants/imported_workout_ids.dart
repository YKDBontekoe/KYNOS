import 'package:uuid/uuid.dart';

/// Prefix and helpers for locally imported workout identifiers.
abstract final class ImportedWorkoutIds {
  static const prefix = 'import:';

  static bool isImported(String id) => id.startsWith(prefix);

  static String generate() => '$prefix${const Uuid().v4()}';
}
