import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';

class AdminDocumentTypesScreen extends StatefulWidget {
  const AdminDocumentTypesScreen({super.key});

  @override
  State<AdminDocumentTypesScreen> createState() => _AdminDocumentTypesScreenState();
}

class _AdminDocumentTypesScreenState extends State<AdminDocumentTypesScreen> {
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
    ApiService.invalidateDocumentTypesCache();
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

  void _showForm({Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name']?.toString() ?? '');
    final feeCtrl = TextEditingController(text: existing?['fee']?.toString() ?? '');
    final timeCtrl = TextEditingController(text: existing?['processingTime']?.toString() ?? '');
    final descCtrl = TextEditingController(text: existing?['description']?.toString() ?? '');
    bool isActive = existing != null ? (existing['isActive'] ?? true) as bool : true;
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? 'Edit Document Type' : 'New Document Type',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(labelText: 'Document Name', prefixIcon: Icon(Icons.description_outlined)),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: feeCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Fee (₱)', prefixIcon: Icon(Icons.payments_outlined)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: timeCtrl,
                                    decoration: const InputDecoration(labelText: 'Processing Time', prefixIcon: Icon(Icons.timer_outlined)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: descCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(labelText: 'Description (optional)', prefixIcon: Icon(Icons.notes_rounded)),
                            ),
                            const SizedBox(height: 14),
                            // Active toggle
                            GlassContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Active', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                subtitle: Text(
                                  isActive ? 'Visible to students' : 'Hidden from students',
                                  style: TextStyle(fontSize: 12, color: isActive ? Colors.green : const Color(0xFF94A3B8)),
                                ),
                                value: isActive,
                                onChanged: (v) => setModalState(() => isActive = v),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
                                    onPressed: () async {
                                      if (!formKey.currentState!.validate()) return;
                                      Navigator.pop(ctx);
                                      await _saveType(
                                        existing: existing,
                                        name: nameCtrl.text.trim(),
                                        fee: feeCtrl.text.trim(),
                                        processingTime: timeCtrl.text.trim(),
                                        description: descCtrl.text.trim(),
                                        isActive: isActive,
                                      );
                                    },
                                    child: Text(isEdit ? 'Save Changes' : 'Create', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveType({
    Map<String, dynamic>? existing,
    required String name,
    required String fee,
    required String processingTime,
    required String description,
    required bool isActive,
  }) async {
    final data = {
      'name': name,
      if (fee.isNotEmpty) 'fee': double.tryParse(fee) ?? fee,
      if (processingTime.isNotEmpty) 'processingTime': processingTime,
      if (description.isNotEmpty) 'description': description,
      'isActive': isActive,
    };

    Map<String, dynamic> result;
    if (existing != null) {
      result = await ApiService.updateDocumentType(existing['id'], data);
    } else {
      result = await ApiService.createDocumentType(data);
    }

    if (!mounted) return;
    if (result['success'] == true) {
      _showSnack(existing != null ? 'Document type updated' : 'Document type created', isError: false);
      _loadTypes();
    } else {
      _showSnack(result['message'] ?? 'Operation failed', isError: true);
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> doc) async {
    final newState = !(doc['isActive'] ?? true);
    final result = await ApiService.updateDocumentType(doc['id'], {
      ...Map<String, dynamic>.from(doc),
      'isActive': newState,
    });
    if (!mounted) return;
    if (result['success'] == true) {
      _showSnack(newState ? 'Document type activated' : 'Document type deactivated', isError: false);
      _loadTypes();
    } else {
      _showSnack(result['message'] ?? 'Failed to update', isError: true);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => Center(
        child: GlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              const Text('Delete Document Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 10),
              Text(
                'Delete "${doc['name']}"? This cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteDocumentType(doc['id']);
      if (!mounted) return;
      if (success) {
        _showSnack('Document type deleted', isError: false);
        _loadTypes();
      } else {
        _showSnack('Failed to delete', isError: true);
      }
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF1A237E),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Types', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadTypes),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Type', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          Icon(Icons.folder_copy_outlined, size: 72, color: Colors.black.withValues(alpha: 0.12)),
                          const SizedBox(height: 16),
                          const Text('No document types yet', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => _showForm(),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Create First Type'),
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTypes,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _documentTypes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = _documentTypes[index] as Map<String, dynamic>;
                          final isActive = doc['isActive'] ?? true;
                          return _DocTypeCard(
                            doc: doc,
                            isActive: isActive,
                            onEdit: () => _showForm(existing: doc),
                            onToggle: () => _toggleActive(doc),
                            onDelete: () => _confirmDelete(doc),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}

class _DocTypeCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _DocTypeCard({
    required this.doc,
    required this.isActive,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = (doc['name'] ?? 'Document').toString();
    final fee = doc['fee'];
    final processingTime = doc['processingTime']?.toString();

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42, width: 42,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF1A237E).withValues(alpha: 0.08)
                      : const Color(0xFF94A3B8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.description_outlined,
                  color: isActive ? const Color(0xFF1A237E) : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : const Color(0xFF94A3B8).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.green : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                  color: isActive ? Colors.green : const Color(0xFF94A3B8),
                  size: 28,
                ),
                tooltip: isActive ? 'Deactivate' : 'Activate',
                onPressed: onToggle,
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_rounded, size: 20, color: Color(0xFF1A237E)),
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                tooltip: 'Delete',
                onPressed: onDelete,
              ),
            ],
          ),
          if (fee != null || (processingTime != null && processingTime.isNotEmpty)) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                if (fee != null)
                  _Chip(icon: Icons.payments_outlined, label: '₱$fee', color: const Color(0xFF16A34A)),
                if (processingTime != null && processingTime.isNotEmpty)
                  _Chip(icon: Icons.timer_outlined, label: processingTime, color: const Color(0xFFF59E0B)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
