import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import '../models/user_model.dart';
import '../widgets/notification_modal.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'request_document_screen.dart';
import 'track_requests_screen.dart';
import 'profile_screen.dart';
import 'document_types_screen.dart';
import 'announcements_screen.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/glassy_bottom_nav.dart';

class StudentDashboard extends StatefulWidget {
  final UserModel user;

  const StudentDashboard({super.key, required this.user});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final ValueNotifier<bool> _isSyncing = ValueNotifier<bool>(true);
  
  int _notificationCount = 0;
  List<dynamic> _activeTrackingList = [];
  int _completedCount = 0;
  int _ongoingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _isSyncing.dispose();
    super.dispose();
  }

  // --- LOGIC: WORKFLOW CHECKERS ---
  
  // Mahuman lang ang tracking kung na "Download" na o "Completed" na gyud.
  bool _isArchived(String status) {
    final s = status.toLowerCase();
    return s == 'download' || s == 'completed';
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    _isSyncing.value = true;

    try {
      // Run both requests in parallel
      final results = await Future.wait([
        ApiService.getDocumentRequestsByUserId(widget.user.id ?? 0),
        ApiService.getAnnouncements(),
        AuthService.getPrefsInstance().then((p) => p.getString('lastClearedNotificationsTime')),
      ]);

      final requests = results[0] as List<dynamic>;
      final announcements = results[1] as List<dynamic>;
      final clearedTimeStr = results[2] as String?;
      final DateTime? clearedTime = clearedTimeStr != null ? DateTime.tryParse(clearedTimeStr) : null;

      if (mounted) {
        // Only count announcements newer than last cleared time
        int activeNotifs = 0;
        for (var a in announcements) {
          final dt = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.now();
          if (clearedTime == null || dt.isAfter(clearedTime)) activeNotifs++;
        }

        final List<dynamic> activeWorkflow = requests.where((r) {
          final String s = (r['status'] ?? '').toString();
          final String lower = s.toLowerCase();
          if (lower == 'rejected' || lower == 'cancelled') return false;
          return !_isArchived(s);
        }).toList();

        // Count request updates newer than cleared time
        int requestNotifs = 0;
        for (var r in requests) {
          final String lower = (r['status'] ?? '').toString().toLowerCase();
          if (lower == 'request' || lower == 'pending') continue;
          final dt = DateTime.tryParse(r['updatedAt']?.toString() ?? r['requestDate']?.toString() ?? '') ?? DateTime.now();
          if (clearedTime == null || dt.isAfter(clearedTime)) requestNotifs++;
        }

        final completed = requests.where((r) => _isArchived((r['status'] ?? '').toString())).length;

        setState(() {
          _activeTrackingList = activeWorkflow.take(5).toList();
          _completedCount = completed;
          _ongoingCount = activeWorkflow.length;
          _notificationCount = activeNotifs + requestNotifs;
          _isSyncing.value = false;
        });
      }
    } catch (e) {
      if (mounted) _isSyncing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(),
      body: GradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: const Color(0xFF1A237E),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildNewRequestCard(),
                const SizedBox(height: 12),
                _buildAnnouncementsButton(),
                const SizedBox(height: 8),
                _buildDocumentTypesButton(),
                const SizedBox(height: 24),
                _buildActiveTrackingSection(),
                const SizedBox(height: 24),
                const Text('Quick Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _buildStatsRow(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: GlassyBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackRequestsScreen()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Row(
        children: [
          Icon(Icons.school_rounded, size: 24, color: Color(0xFF1A237E)),
          SizedBox(width: 10),
          Text('RegisTrack', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
        ],
      ),
      actions: [
        badges.Badge(
          badgeContent: Text('$_notificationCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          showBadge: _notificationCount > 0,
          position: badges.BadgePosition.topEnd(top: 10, end: 8),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1A237E)),
            onPressed: () => _showNotifications(context),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WELCOME BACK,', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.2)),
        Text(
          widget.user.firstName.toUpperCase(),
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _buildDocumentTypesButton() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentTypesScreen())),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.folder_copy_outlined, color: Color(0xFF1A237E), size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Document Types & Fees',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsButton() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen())),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.campaign_rounded, color: Color(0xFF1A237E), size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Announcements',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewRequestCard() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      backgroundColor: const Color(0xFF1A237E),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestDocumentScreen())),
        borderRadius: BorderRadius.circular(16),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 32),
              SizedBox(height: 8),
              Text('Request New Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Active Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackRequestsScreen())),
              child: const Text('View All', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: _isSyncing,
          builder: (context, loading, _) {
            if (loading) return const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(strokeWidth: 3)));
            
            if (_activeTrackingList.isEmpty) {
              return const GlassContainer(
                padding: EdgeInsets.all(30),
                child: Center(child: Text('No active document requests', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
              );
            }

            return Column(
              children: _activeTrackingList.map((request) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActiveRequestCard(
                  title: (request['documentTypeName'] ?? 'Document').toString(),
                  reference: (request['referenceNumber'] ?? 'REF-${request['id']}').toString(),
                  rawStatus: (request['status'] ?? 'Request').toString(),
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _MiniStatCard(value: '$_completedCount', label: 'COMPLETED', icon: Icons.check_circle_rounded, color: Colors.green.shade600)),
        const SizedBox(width: 12),
        Expanded(child: _MiniStatCard(value: '$_ongoingCount', label: 'ONGOING', icon: Icons.hourglass_top_rounded, color: Colors.orange.shade700)),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationModal(),
    ).then((_) => _loadDashboardData());
  }
}

// --- SUB-WIDGETS ---

class _ActiveRequestCard extends StatelessWidget {
  final String title;
  final String reference;
  final String rawStatus;

  const _ActiveRequestCard({required this.title, required this.reference, required this.rawStatus});

  @override
  Widget build(BuildContext context) {
    final status = _getStatusConfig(rawStatus);
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(reference, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              _StatusBadge(label: status.label, color: status.color),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: status.progress,
              backgroundColor: const Color(0xFFE2E8F0),
              color: status.color,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status.subLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
              Text('${(status.progress * 100).round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: status.color)),
            ],
          ),
        ],
      ),
    );
  }

  _StatusData _getStatusConfig(String raw) {
    final s = raw.toLowerCase();
    
    // 1. RECEIVE / READY
    if (s == 'receive' || s == 'ready') {
      return const _StatusData('READY', 'Ready for Pickup at Office', 0.95, Color(0xFF0891B2));
    }
    // 2. APPROVE / APPROVED
    if (s == 'approve' || s == 'approved') {
      return const _StatusData('APPROVED', 'Document is being prepared', 0.75, Color(0xFF16A34A));
    }
    // 3. IN PROCESS
    if (s == 'inprocess' || s == 'in process' || s == 'processing') {
      return const _StatusData('IN PROCESS', 'Staff is processing records', 0.50, Color(0xFF1E40AF));
    }
    // 4. DEFAULT: REQUEST / PENDING
    return const _StatusData('REQUESTED', 'Waiting for acknowledgment', 0.25, Color(0xFF64748B));
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _MiniStatCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
            ],
          )
        ],
      ),
    );
  }
}

class _StatusData {
  final String label;
  final String subLabel;
  final double progress;
  final Color color;
  const _StatusData(this.label, this.subLabel, this.progress, this.color);
}