import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract final class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  static Future<XFile?> pickFromCamera() async {
    return _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  static Future<XFile?> pickMultiFromGallery() async {
    final images = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return images.isNotEmpty ? images.first : null;
  }

  static bool isValidImageSize(File file, {double maxMb = 5}) {
    final bytes = file.readAsBytesSync().length;
    return bytes / (1024 * 1024) <= maxMb;
  }
}
