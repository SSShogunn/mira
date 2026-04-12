import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cobalt_instance.dart';
import '../services/cobalt_service.dart';

class InstanceScreen extends StatefulWidget {
  final CobaltInstance? instance; // null = new, not null = edit
  const InstanceScreen({super.key, this.instance});

  @override
  State<InstanceScreen> createState() => _InstanceScreenState();
}

class _InstanceScreenState extends State<InstanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _apiKeyController = TextEditingController();

  bool _authEnabled = false;
  bool _isDefault = false;
  bool _isTesting = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Edit mode — existing data fill karo
    if (widget.instance != null) {
      _nameController.text = widget.instance!.name;
      _urlController.text = widget.instance!.url;
      _apiKeyController.text = widget.instance!.apiKey ?? '';
      _authEnabled = widget.instance!.authEnabled;
      _isDefault = widget.instance!.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  String _normalizeUrl(String url) {
    url = url.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }

  // Connection test karo
  Future<void> _testConnection() async {
    if (_urlController.text.isEmpty) return;

    setState(() => _isTesting = true);

    final instance = CobaltInstance(
      name: 'test',
      url: _normalizeUrl(_urlController.text),
      authEnabled: _authEnabled,
      apiKey: _apiKeyController.text.trim(),
    );

    final success = await CobaltService.testConnection(instance);

    if (mounted) {
      setState(() => _isTesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ Connected!' : '❌ Connection failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // Save karo
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final box = Hive.box<CobaltInstance>('instances');

    // Agar isDefault true hai toh baaki sab false karo
    if (_isDefault) {
      for (var i = 0; i < box.length; i++) {
        final inst = box.getAt(i)!;
        inst.isDefault = false;
        inst.save();
      }
    }

    if (widget.instance != null) {
      // Edit mode
      widget.instance!
        ..name = _nameController.text.trim()
        ..url = _normalizeUrl(_urlController.text)
        ..authEnabled = _authEnabled
        ..apiKey = _authEnabled ? _apiKeyController.text.trim() : null
        ..isDefault = _isDefault;
      await widget.instance!.save();
    } else {
      // New instance
      await box.add(
        CobaltInstance(
          name: _nameController.text.trim(),
          url: _normalizeUrl(_urlController.text),
          authEnabled: _authEnabled,
          apiKey: _authEnabled ? _apiKeyController.text.trim() : null,
          isDefault: _isDefault,
        ),
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.instance != null ? 'Edit Instance' : 'Add Instance'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'My Cobalt',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 16),

            // URL field
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Instance URL',
                hintText: 'cobalt.example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.isEmpty) return 'URL required';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Test connection button
            OutlinedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
            ),
            const SizedBox(height: 24),

            // Auth toggle
            SwitchListTile(
              title: const Text('Authentication'),
              subtitle: const Text('Enable if your instance requires API key'),
              value: _authEnabled,
              onChanged: (v) => setState(() => _authEnabled = v),
            ),

            // API Key field — sirf auth enabled hone pe dikhega
            if (_authEnabled) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
                obscureText: true,
                validator: (v) {
                  if (_authEnabled && (v == null || v.isEmpty)) {
                    return 'API key required when auth is enabled';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),

            // Default instance toggle
            SwitchListTile(
              title: const Text('Set as Default'),
              subtitle: const Text('Use this instance for all downloads'),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
