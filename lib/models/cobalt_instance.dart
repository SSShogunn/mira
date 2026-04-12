import 'package:hive/hive.dart';

part 'cobalt_instance.g.dart'; // yeh build_runner generate karega

@HiveType(typeId: 0) // har model ka unique ID hota hai
class CobaltInstance extends HiveObject {
  
  @HiveField(0)
  late String name; // "My Cobalt", "Home Server" etc

  @HiveField(1)
  late String url; // "https://cobalt.ssshogunnn.info"

  @HiveField(2)
  bool authEnabled; // API key chahiye ya nahi

  @HiveField(3)
  String? apiKey; // optional

  @HiveField(4)
  bool isDefault; // default instance hai ya nahi

  CobaltInstance({
    required this.name,
    required this.url,
    this.authEnabled = false,
    this.apiKey,
    this.isDefault = false,
  });
}