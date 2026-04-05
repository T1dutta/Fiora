import 'package:flutter/material.dart';

import '../services/fiora_api.dart';

/// Lists server-side alerts (e.g. SEVERE_CRAMPS) from GET /api/v1/alerts.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _api = FioraApi();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.fetchAlerts();
      if (mounted) {
        setState(() {
          _items = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F4F2),
      appBar: AppBar(
        title: const Text('Health alerts'),
        backgroundColor: const Color(0xff4F6B52),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : _items.isEmpty
                  ? const Center(child: Text('No alerts yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final a = _items[i];
                        final type = a['type']?.toString() ?? '';
                        final msg = a['message']?.toString() ?? '';
                        final status = a['status']?.toString() ?? '';
                        final created = a['created_at']?.toString() ?? '';
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              type == 'SEVERE_CRAMPS'
                                  ? Icons.warning_amber_rounded
                                  : Icons.notifications_none,
                              color: const Color(0xffB65A3A),
                            ),
                            title: Text(type.replaceAll('_', ' ')),
                            subtitle: Text('$msg\n$created\nStatus: $status'),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
    );
  }
}
