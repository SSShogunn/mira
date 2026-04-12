import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_handler/share_handler.dart';
import 'models/cobalt_instance.dart';
import 'screens/home_screen.dart';
import 'models/download_history.dart';

// Global stream — HomeScreen listens to this for incoming shared URLs
final sharedUrlStream = StreamController<String>.broadcast();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CobaltInstanceAdapter());
  Hive.registerAdapter(DownloadHistoryAdapter());
  await Hive.openBox<CobaltInstance>('instances');
  await Hive.openBox<DownloadHistory>('history');
  runApp(const MiraApp());
}

class MiraApp extends StatefulWidget {
  const MiraApp({super.key});

  @override
  State<MiraApp> createState() => _MiraAppState();
}

class _MiraAppState extends State<MiraApp> {
  @override
  void initState() {
    super.initState();
    _initShareHandler();
  }

  Future<void> _initShareHandler() async {
    final handler = ShareHandler.instance;

    handler.sharedMediaStream.listen((SharedMedia media) {
      _handleSharedUrl(media.content);
    });

    final initial = await handler.getInitialSharedMedia();
    if (initial?.content != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSharedUrl(initial!.content);
      });
    }
  }

  void _handleSharedUrl(String? url) {
    if (url == null || url.isEmpty) return;
    if (!url.startsWith('http')) return;
    sharedUrlStream.add(url);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mira',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
