import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cobalt_instance.dart';
import '../models/download_history.dart';
import '../services/cobalt_service.dart';

class DownloadSheet extends StatefulWidget {
  final CobaltInstance instance;
  final String? initialUrl;

  const DownloadSheet({super.key, required this.instance, this.initialUrl});

  @override
  State<DownloadSheet> createState() => _DownloadSheetState();
}

class _DownloadSheetState extends State<DownloadSheet> {
  final _urlController = TextEditingController();
  bool _audioOnly = false;
  bool _isLoading = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _saveHistory(
    String url,
    String filename,
    String status, {
    String? error,
    String? filePath,
  }) {
    final box = Hive.box<DownloadHistory>('history');
    box.add(
      DownloadHistory(
        url: url,
        filename: filename,
        downloadedAt: DateTime.now(),
        status: status,
        errorMessage: error,
        filePath: filePath,
      ),
    );
  }

  Future<void> _download() async {
    if (_urlController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _status = '🔍 Fetching download link...';
    });

    await CobaltService.fetchAndDownload(
      instance: widget.instance,
      mediaUrl: _urlController.text.trim(),
      audioOnly: _audioOnly,
      onProgress: (received, total) {
        if (total > 0 && mounted) {
          final percent = (received / total * 100).toStringAsFixed(0);
          setState(() => _status = '⬇️ Downloading... $percent%');
        }
      },
      onSuccess: (filename, filePath) {
        _saveHistory(
          _urlController.text.trim(),
          filename,
          'success',
          filePath: filePath,
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
            _status = '✅ Saved: $filename';
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context);
          });
        }
      },
      onError: (err) {
        _saveHistory(
          _urlController.text.trim(),
          'unknown',
          'failed',
          error: err,
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
            _status = '❌ $err';
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.instance.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // URL input
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'Paste URL here...',
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
          const SizedBox(height: 12),

          // Audio only toggle
          SwitchListTile(
            title: const Text('Audio Only'),
            value: _audioOnly,
            onChanged: (v) => setState(() => _audioOnly = v),
            contentPadding: EdgeInsets.zero,
          ),

          // Status message
          if (_status != null) ...[
            const SizedBox(height: 8),
            Text(
              _status!,
              style: TextStyle(
                color: _status!.startsWith('❌') ? Colors.red : Colors.green,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Download button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _download,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isLoading ? 'Processing...' : 'Download'),
            ),
          ),
        ],
      ),
    );
  }
}
