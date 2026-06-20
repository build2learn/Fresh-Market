import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart';

class FileSaver {
  static Future<void> saveFile(List<int> bytes, String fileName, String mimeType) async {
    await saveFileImpl(bytes, fileName, mimeType);
  }
}
