import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';

class DocumentRequirementsScreen extends StatefulWidget {
  const DocumentRequirementsScreen({super.key});

  @override
  State<DocumentRequirementsScreen> createState() => _DocumentRequirementsScreenState();
}

class _DocumentRequirementsScreenState extends State<DocumentRequirementsScreen> {
  bool _isLoading = true;
  List<dynamic> _documentTypes = [];
  List<dynamic> _requirements = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getDocumentTypes(),
        ApiService.getDocumentRequirements(),
      ]);
      if (mounted) {
        setState(() {
          _documentTypes = results[0];
          _requirements = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requirements', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _documentTypes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 64, color: Colors.black.withOpacity(0.12)),
                          const SizedBox(height: 16),
                          const Text('No information available', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: _documentTypes.length,
                        itemBuilder: (context, index) {
                          final docType = _documentTypes[index];
                          final typeRequirements = _requirements
                              .where((req) => req['documentTypeId'] == docType['id'])
                              .toList();
                          
                          return _DocumentTypeCard(
                            name: docType['name'] ?? 'Document',
                            requirements: typeRequirements,
                            processingTime: docType['processingTime'],
                            fee: docType['fee'],
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}

class _DocumentTypeCard extends StatelessWidget {
  final String name;
  final List<dynamic> requirements;
  final String? processingTime;
  final dynamic fee;

  const _DocumentTypeCard({
    required this.name,
    required this.requirements,
    this.processingTime,
    this.fee,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: const Color(0xFF64748B),
          iconColor: Theme.of(context).colorScheme.primary,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.description_rounded, color: Theme.of(context).colorScheme.primary, size: 22),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
          ),
          subtitle: Text(
            '${requirements.length} ${requirements.length == 1 ? 'requirement' : 'requirements'}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Divider(color: Color(0xFFE7E9F4)),
                   const SizedBox(height: 12),
                   if (requirements.isEmpty)
                     const Text('No specific requirements found for this document.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontStyle: FontStyle.italic))
                   else
                     ...requirements.map((req) => Padding(
                       padding: const EdgeInsets.only(bottom: 10),
                       child: Row(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF16A34A)),
                           const SizedBox(width: 12),
                           Expanded(child: Text(req['description'] ?? req['name'] ?? 'Requirement', style: const TextStyle(color: Color(0xFF334155), fontSize: 14))),
                         ],
                       ),
                     )),
                   const SizedBox(height: 20),
                   Row(
                     children: [
                       if (processingTime != null)
                         Expanded(
                           child: _InfoChip(icon: Icons.timer_outlined, label: processingTime!, color: Colors.orangeAccent),
                         ),
                       if (processingTime != null && fee != null) const SizedBox(width: 12),
                       if (fee != null)
                         Expanded(
                           child: _InfoChip(icon: Icons.payments_outlined, label: '₱$fee', color: const Color(0xFF16A34A)),
                         ),
                     ],
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(child: Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
