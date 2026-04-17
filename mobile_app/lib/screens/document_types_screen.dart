import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';

class DocumentTypesScreen extends StatefulWidget {
  const DocumentTypesScreen({super.key});

  @override
  State<DocumentTypesScreen> createState() => _DocumentTypesScreenState();
}

class _DocumentTypesScreenState extends State<DocumentTypesScreen> {
  bool _isLoading = true;
  List<dynamic> _documentTypes = [];

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final types = await ApiService.getDocumentTypes();
      if (!mounted) return;
      setState(() {
        _documentTypes = types;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showDetails(Map<String, dynamic> doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            final name = (doc['name'] ?? 'Document').toString();
            final fee = doc['fee'];
            final processingTime = doc['processingTime']?.toString();
            final description = doc['description']?.toString();
            final requirements = doc['requirements'] as List<dynamic>? ?? [];

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.description_rounded, color: Color(0xFF1A237E), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Fee & Processing Time chips
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (fee != null)
                              _DetailChip(
                                icon: Icons.payments_outlined,
                                label: 'Fee',
                                value: '₱$fee',
                                color: const Color(0xFF16A34A),
                              ),
                            if (processingTime != null && processingTime.isNotEmpty)
                              _DetailChip(
                                icon: Icons.timer_outlined,
                                label: 'Processing Time',
                                value: processingTime,
                                color: const Color(0xFFF59E0B),
                              ),
                          ],
                        ),

                        if (description != null && description.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const _SectionLabel(label: 'DESCRIPTION'),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        const _SectionLabel(label: 'REQUIREMENTS'),
                        const SizedBox(height: 12),
                        if (requirements.isEmpty)
                          const Text(
                            'No specific requirements listed.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontStyle: FontStyle.italic),
                          )
                        else
                          ...requirements.map((req) {
                            final reqName = (req['description'] ?? req['name'] ?? req.toString()).toString();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF16A34A)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      reqName,
                                      style: const TextStyle(color: Color(0xFF334155), fontSize: 14, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Types & Fees', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadTypes),
          const SizedBox(width: 8),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _documentTypes.isEmpty
                  ? const Center(
                      child: Text(
                        'No document types available',
                        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTypes,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _documentTypes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = _documentTypes[index] as Map<String, dynamic>;
                          final name = (doc['name'] ?? 'Document').toString();
                          final fee = doc['fee'];
                          final processingTime = doc['processingTime']?.toString();

                          return GlassContainer(
                            padding: EdgeInsets.zero,
                            child: InkWell(
                              onTap: () => _showDetails(doc),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 44,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              if (processingTime != null && processingTime.isNotEmpty)
                                                _InfoChip(icon: Icons.timer_outlined, label: processingTime),
                                              if (fee != null)
                                                _InfoChip(icon: Icons.payments_outlined, label: '₱$fee'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E9F4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}
