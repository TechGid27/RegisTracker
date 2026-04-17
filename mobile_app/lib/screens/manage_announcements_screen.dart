import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/announcement_model.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';

class ManageAnnouncementsScreen extends StatefulWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  State<ManageAnnouncementsScreen> createState() => _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState extends State<ManageAnnouncementsScreen> {
  bool _isLoading = true;
  List<AnnouncementModel> _announcements = [];

  static const _navy = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getAnnouncements();
      if (mounted) {
        setState(() {
          _announcements = data.map((json) => AnnouncementModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForm({AnnouncementModel? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final bodyCtrl = TextEditingController(text: existing?.body ?? '');
    final formKey = GlobalKey<FormState>();
    final isSaving = ValueNotifier(false);
    final isEdit = existing != null;
    final expiryNotifier = ValueNotifier<DateTime>(
      DateTime.now().add(const Duration(days: 30)),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _navy.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.campaign_rounded, color: _navy, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isEdit ? 'Edit Announcement' : 'New Announcement',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Title
                          TextFormField(
                            controller: titleCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              prefixIcon: Icon(Icons.title_rounded),
                              helperText: 'Min 5 characters',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Title is required';
                              if (v.trim().length < 5) return 'Title must be at least 5 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Message
                          TextFormField(
                            controller: bodyCtrl,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Message',
                              prefixIcon: Icon(Icons.notes_rounded),
                              alignLabelWithHint: true,
                              helperText: 'Min 10 characters',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Message is required';
                              if (v.trim().length < 10) return 'Message must be at least 10 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Expiry date picker
                          ValueListenableBuilder<DateTime>(
                            valueListenable: expiryNotifier,
                            builder: (_, expiry, __) => GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: expiry,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                  helpText: 'Select Expiry Date',
                                );
                                if (picked != null) expiryNotifier.value = picked;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_rounded, size: 20, color: _navy),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Expiry Date',
                                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DateFormat('MMMM dd, yyyy').format(expiry),
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Buttons
                          ValueListenableBuilder<bool>(
                            valueListenable: isSaving,
                            builder: (_, saving, __) => Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: saving ? null : () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _navy,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    onPressed: saving
                                        ? null
                                        : () async {
                                            if (!formKey.currentState!.validate()) return;
                                            isSaving.value = true;
                                            Navigator.pop(ctx);
                                            if (isEdit) {
                                              await _update(
                                                existing.id,
                                                titleCtrl.text.trim(),
                                                bodyCtrl.text.trim(),
                                                expiryNotifier.value,
                                              );
                                            } else {
                                              await _create(
                                                titleCtrl.text.trim(),
                                                bodyCtrl.text.trim(),
                                                expiryNotifier.value,
                                              );
                                            }
                                          },
                                    child: saving
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : Text(isEdit ? 'Save Changes' : 'Post', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Future<void> _create(String title, String body, DateTime expiry) async {
    try {
      final user = await AuthService.getCurrentUser();
      final result = await ApiService.createAnnouncement({
        'title': title,
        'content': body,
        'priority': 'Normal',
        'createdBy': user?.id ?? 0,
        'expiryDate': expiry.toIso8601String(),
      });
      if (!mounted) return;
      _snack(
        result['success'] == true ? 'Announcement posted' : (result['message'] ?? 'Failed'),
        isError: result['success'] != true,
      );
      if (result['success'] == true) _loadAnnouncements();
    } catch (e) {
      if (mounted) _snack('Error: $e', isError: true);
    }
  }

  Future<void> _update(int id, String title, String body, DateTime expiry) async {
    try {
      final user = await AuthService.getCurrentUser();
      final result = await ApiService.updateAnnouncement(id, {
        'id': id,
        'title': title,
        'content': body,
        'priority': 'Normal',
        'createdBy': user?.id ?? 0,
        'expiryDate': expiry.toIso8601String(),
      });
      if (!mounted) return;
      _snack(
        result['success'] == true ? 'Announcement updated' : (result['message'] ?? 'Failed'),
        isError: result['success'] != true,
      );
      if (result['success'] == true) _loadAnnouncements();
    } catch (e) {
      if (mounted) _snack('Error: $e', isError: true);
    }
  }

  Future<void> _confirmDelete(AnnouncementModel a) async {
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
              const Text('Delete Announcement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 10),
              Text(
                'Delete "${a.title}"? This cannot be undone.',
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
      final success = await ApiService.deleteAnnouncement(a.id);
      if (!mounted) return;
      _snack(success ? 'Announcement deleted' : 'Failed to delete', isError: !success);
      if (success) _loadAnnouncements();
    }
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : _navy,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Announcements', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadAnnouncements),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _announcements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.campaign_rounded, size: 80, color: Colors.black.withValues(alpha: 0.12)),
                          const SizedBox(height: 16),
                          const Text('No announcements yet', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => _showForm(),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Create First'),
                            style: FilledButton.styleFrom(backgroundColor: _navy),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAnnouncements,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _announcements.length,
                        itemBuilder: (context, index) {
                          final a = _announcements[index];
                          return _AnnouncementCard(
                            announcement: a,
                            onEdit: () => _showForm(existing: a),
                            onDelete: () => _confirmDelete(a),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnnouncementCard({required this.announcement, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.campaign_outlined, color: Color(0xFF1A237E), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  announcement.title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF1A237E)),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            announcement.body,
            style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.5, fontWeight: FontWeight.w600),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xFF94A3B8)),
              const SizedBox(width: 5),
              Text(
                DateFormat('MMM dd, yyyy').format(announcement.createdAt),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700),
              ),
              if (announcement.updatedAt != null) ...[
                const SizedBox(width: 14),
                const Icon(Icons.history_rounded, size: 11, color: Color(0xFF94A3B8)),
                const SizedBox(width: 5),
                Text(
                  'Updated ${DateFormat('MMM dd, yyyy').format(announcement.updatedAt!)}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
