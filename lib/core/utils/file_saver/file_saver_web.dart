import 'dart:html' as html;
import 'package:flutter/foundation.dart';

Future<void> saveFileImpl(List<int> bytes, String fileName, String mimeType) async {
  try {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
    debugPrint('[WEB FILE SAVER] Successfully triggered web download for: $fileName');
  } catch (e) {
    debugPrint('[WEB FILE SAVER] Failed to trigger download: $e');
  }
}
