import 'package:flutter/foundation.dart';

List<int>? lastSavedBytes;
String? lastSavedFileName;
String? lastSavedMimeType;

Future<void> saveFileImpl(List<int> bytes, String fileName, String mimeType) async {
  lastSavedBytes = bytes;
  lastSavedFileName = fileName;
  lastSavedMimeType = mimeType;
  debugPrint('[STUB FILE SAVER] Saved file: $fileName ($mimeType) with ${bytes.length} bytes');
}
