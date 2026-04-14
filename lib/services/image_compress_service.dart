import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ImageCompressService {
  /// Compress an image file before uploading
  /// Returns a compressed File with significantly reduced size
  ///
  /// Default settings:
  /// - Max width/height: 800px (sufficient for chat images)
  /// - Quality: 70% (good balance between quality and size)
  /// - Format: JPEG
  static Future<File> compressImage(
    File file, {
    int maxWidth = 800,
    int maxHeight = 800,
    int quality = 70,
  }) async {
    // Get temp directory for output
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Compress the image
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      final compressedFile = File(result.path);

      // Log compression results
      final originalSize = await file.length();
      final compressedSize = await compressedFile.length();
      final savedPercent = ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);
      print('Image compressed: ${_formatBytes(originalSize)} -> ${_formatBytes(compressedSize)} (saved $savedPercent%)');

      return compressedFile;
    }

    // Return original if compression failed
    return file;
  }

  /// Format bytes to human readable string
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
