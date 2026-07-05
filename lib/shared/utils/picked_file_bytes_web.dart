import 'package:file_picker/file_picker.dart';

Future<List<int>> readPickedFileBytes(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes != null) {
    return bytes;
  }
  throw const FormatException('Could not read the selected file.');
}
