import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'qnvz3cfm';
  static const String uploadPreset = 'campus_lost_found';

  static Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (imageBytes.isEmpty) {
      throw Exception('File foto kosong.');
    }

    if (imageBytes.length > 5 * 1024 * 1024) {
      throw Exception('Ukuran foto maksimal 5 MB.');
    }

    final extension = fileName.split('.').last.toLowerCase();

    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      throw Exception('Format foto harus JPG, PNG, atau WEBP.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Gagal mengunggah foto: $body');
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    final imageUrl = data['secure_url'] as String?;

    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('URL foto tidak ditemukan.');
    }

    return imageUrl;
  }
}
