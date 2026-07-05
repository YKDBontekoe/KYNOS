import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<List<int>> readPickedFileBytes(PlatformFile file) async {
  final path = file.path;
  if (path != null) {
    return File(path).readAsBytes();
  }
  final bytes = file.bytes;
  if (bytes != null) {
    return bytes;
  }
  throw const FormatException('Could not read the selected file.');
}
