import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';

class PublicLookupScreen extends StatefulWidget {
  const PublicLookupScreen({super.key});

  @override
  State<PublicLookupScreen> createState() => _PublicLookupScreenState();
}

class _PublicLookupScreenState extends State<PublicLookupScreen> {
  final _referenceController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final reference = _referenceController.text.trim();
    if (reference.isEmpty) {
      setState(() {
        _error = 'Enter a reference number';
        _result = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final data = await ApiService.getDocumentRequestByReference(reference);
      if (!mounted) return;
      if (data == null) {
        setState(() {
          _error = 'No record found for that reference number';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _result = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Lookup failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Lookup', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Track a request using its reference number.',
                      style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _referenceController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _lookup(),
                      decoration: const InputDecoration(
                        labelText: 'Reference Number',
                        prefixIcon: Icon(Icons.qr_code_2_rounded),
                        hintText: 'e.g. REF-12345',
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _lookup,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.search_rounded),
                        label: const Text('Lookup', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
                  borderColor: const Color(0xFFEF4444).withOpacity(0.35),
                  boxShadow: const [],
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              if (_result != null) ...[
                const SizedBox(height: 12),
                _ResultCard(result: _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const _ResultCard({required this.result});

  String _formatDate(dynamic value) {
    if (value == null) return 'N/A';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return DateFormat('MMM dd, yyyy').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final reference = (result['referenceNumber'] ?? result['reference'] ?? '').toString();
    final status = (result['status'] ?? 'Unknown').toString();
    final documentType =
        (result['documentTypeName'] ?? result['documentType'] ?? result['documentTypeId'] ?? 'Document').toString();
    final requested = _formatDate(result['requestDate'] ?? result['createdAt']);
    final updated = _formatDate(result['updatedAt']);

    final scheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(status, scheme);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.track_changes_rounded, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Result', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                    Text(
                      reference.isEmpty ? 'Reference' : reference,
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(0.25)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Document', value: documentType),
          _DetailRow(label: 'Requested', value: requested),
          _DetailRow(label: 'Last Update', value: updated),
        ],
      ),
    );
  }

  Color _statusColor(String status, ColorScheme scheme) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
      case 'done':
        return const Color(0xFF16A34A);
      case 'processing':
      case 'in process':
        return const Color(0xFFF59E0B);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'pending':
      case 'request':
      default:
        return scheme.primary;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

