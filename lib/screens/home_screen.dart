import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart' show sharedUrlStream;
import '../models/cobalt_instance.dart';
import '../models/download_history.dart';
import 'instance_screen.dart';
import '../widgets/download_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: const [_HomeTab(), _HistoryTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// ─── Home Tab ────────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _urlController = TextEditingController();
  StreamSubscription<String>? _sharedUrlSub;

  @override
  void initState() {
    super.initState();
    _sharedUrlSub = sharedUrlStream.stream.listen((url) {
      if (mounted) _openDownloadSheet(url: url);
    });
  }

  @override
  void dispose() {
    _sharedUrlSub?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  void _openDownloadSheet({String? url}) {
    final box = Hive.box<CobaltInstance>('instances');
    if (box.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a Cobalt instance first!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final instance = box.getAt(0)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DownloadSheet(
        instance: instance,
        initialUrl: url ?? _urlController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const SizedBox(height: 16),
            Text(
              'Mira',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Paste a link to download',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // URL Input
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'https://...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      _urlController.text = data!.text!;
                    }
                  },
                ),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // Download Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openDownloadSheet(),
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ),
            const SizedBox(height: 32),

            // Instance Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Instance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ValueListenableBuilder(
                  valueListenable: Hive.box<CobaltInstance>(
                    'instances',
                  ).listenable(),
                  builder: (context, Box<CobaltInstance> box, _) {
                    if (box.isEmpty) {
                      return TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InstanceScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      );
                    }
                    return TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              InstanceScreen(instance: box.getAt(0)),
                        ),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Instance Card
            ValueListenableBuilder(
              valueListenable: Hive.box<CobaltInstance>(
                'instances',
              ).listenable(),
              builder: (context, Box<CobaltInstance> box, _) {
                if (box.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_off, color: Colors.grey),
                        SizedBox(width: 12),
                        Text(
                          'No instance configured',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final instance = box.getAt(0)!;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_done, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              instance.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              instance.url,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── History Tab ─────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<DownloadHistory>('history');

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear History'),
                        content: const Text(
                          'Delete all download history?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) await box.clear();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<DownloadHistory> box, _) {
                if (box.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No downloads yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final items = box.values.toList().reversed.toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final hasFile = item.filePath != null &&
                        File(item.filePath!).existsSync();

                    return ListTile(
                      leading: Icon(
                        item.status == 'success'
                            ? Icons.check_circle
                            : Icons.error,
                        color: item.status == 'success'
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(
                        item.filename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _formatDate(item.downloadedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: hasFile
                          ? IconButton(
                              icon: const Icon(Icons.share, size: 20),
                              onPressed: () => Share.shareXFiles(
                                [XFile(item.filePath!)],
                                text: item.filename,
                              ),
                            )
                          : item.status == 'failed'
                              ? const Icon(
                                  Icons.info_outline,
                                  color: Colors.grey,
                                  size: 18,
                                )
                              : null,
                      onTap: () {
                        if (item.status == 'failed' &&
                            item.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(item.errorMessage!),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (hasFile) {
                          OpenFile.open(item.filePath!);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
