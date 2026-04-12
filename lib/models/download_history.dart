import 'package:hive/hive.dart';

part 'download_history.g.dart';

@HiveType(typeId: 1)
class DownloadHistory extends HiveObject {
  @HiveField(0)
  late String url;

  @HiveField(1)
  late String filename;

  @HiveField(5)
  String? filePath;

  @HiveField(2)
  late DateTime downloadedAt;

  @HiveField(3)
  late String status; // 'success' or 'failed'

  @HiveField(4)
  String? errorMessage;

  DownloadHistory({
    required this.url,
    required this.filename,
    required this.downloadedAt,
    required this.status,
    required this.filePath,
    this.errorMessage,
  });
}
