import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/cobalt_instance.dart';

class CobaltService {
  static Future<bool> testConnection(CobaltInstance instance) async {
    try {
      String url = instance.url.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static String _cleanUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtube.com')) {
        final v = uri.queryParameters['v'];
        if (v != null) {
          return Uri(
            scheme: uri.scheme,
            host: uri.host,
            path: uri.path,
            queryParameters: {'v': v},
          ).toString();
        }
      } else if (uri.host.contains('youtu.be')) {
        return Uri(
          scheme: uri.scheme,
          host: uri.host,
          path: uri.path,
        ).toString();
      }
    } catch (_) {}
    return url;
  }

  static Future<void> fetchAndDownload({
    required CobaltInstance instance,
    required String mediaUrl,
    bool audioOnly = false,
    required Function(int, int) onProgress,
    required Function(String filename, String filePath) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final cleanedUrl = _cleanUrl(mediaUrl);

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (instance.authEnabled && instance.apiKey != null)
          'Authorization': 'Api-Key ${instance.apiKey}',
      };

      final body = jsonEncode({
        'url': cleanedUrl,
        if (audioOnly) 'downloadMode': 'audio',
      });

      final response = await http
          .post(Uri.parse(instance.url), headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        onError('Server error: ${response.statusCode}');
        return;
      }

      final json = jsonDecode(response.body);
      final status = json['status'] ?? 'error';

      if (status == 'error') {
        onError(json['error']?['code'] ?? 'Unknown error');
        return;
      }

      final downloadUrl = json['url'] as String?;
      final filename =
          (json['filename'] as String?) ??
          'mira_${DateTime.now().millisecondsSinceEpoch}.mp4';

      if (downloadUrl == null) {
        onError('No download URL received');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final safeFilename = filename
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final tempPath = '${tempDir.path}/$safeFilename';

      final dio = Dio();
      await dio.download(
        downloadUrl,
        tempPath,
        onReceiveProgress: onProgress,
        options: Options(
          receiveTimeout: const Duration(minutes: 10),
          headers: {'User-Agent': 'Mira/1.0'},
        ),
      );

      final tempFile = File(tempPath);
      if (!await tempFile.exists() || await tempFile.length() == 0) {
        onError('Downloaded file is empty');
        return;
      }

      const downloadsPath = '/storage/emulated/0/Download';
      final destPath = '$downloadsPath/$safeFilename';
      await tempFile.copy(destPath);
      await tempFile.delete();

      onSuccess(safeFilename, destPath);
    } catch (e) {
      onError(e.toString());
    }
  }
}
