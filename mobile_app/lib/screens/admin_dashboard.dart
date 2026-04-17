import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/glassy_bottom_nav.dart';
import 'admin_document_types_screen.dart';
import 'manage_announcements_screen.dart';
import 'profile_screen.dart';
import 'track_requests_screen.dart';

class AdminDashboard extends StatefulWidget {
  final UserModel user;

  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  int _totalRequests = 0;
  int _ongoingRequests = 0;
  List<dynamic> _recentRequests = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final requests = await ApiService.getDocumentRequests();

      int ongoing = 0;
      final List<dynamic> recent = [];
      for (final r in requests) {
        final s = (r['status'] ?? '').toString().toLowerCase();
        final isArchived = s == 'rejected' || s == 'cancelled';
        final isDone = s == 'download' || s == 'completed';
        if (!isArchived && !isDone) ongoing++;
        if (!isArchived && recent.length < 3) {
          recent.add(r);
        }
      }

      if (!mounted) return;
      setState(() {
        _totalRequests = requests.length;
        _ongoingRequests = ongoing;
        _recentRequests = recent;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.description_rounded, size: 18, color: scheme.primary),
            ),
            const SizedBox(width: 10),
            const Text('RegisTrack', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildDocumentTypesCard(),
              const SizedBox(height: 20),
              _buildRecentRequests(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GlassyBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackRequestsScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDocumentTypesScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
        items: const [
          {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
          {'icon': Icons.description_rounded, 'label': 'Requests'},
          {'icon': Icons.folder_copy_outlined, 'label': 'Types'},
          {'icon': Icons.person_rounded, 'label': 'Profile'},
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ADMIN PANEL',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Main Dashboard',
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Admin Name - ${widget.user.fullName.isEmpty ? widget.user.firstName : widget.user.fullName}',
          style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GlassContainer(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.dashboard_rounded, color: scheme.primary),
                ),
                const SizedBox(height: 14),
                Text(
                  _isLoading ? '...' : _formatCompactNumber(_totalRequests),
                  style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 22),
                ),
                const SizedBox(height: 4),
                const Text('Total Requests', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.autorenew_rounded, color: Color(0xFFF59E0B), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLoading ? '...' : _ongoingRequests.toString().padLeft(2, '0'),
                            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          const Text(
                            'Ongoing Requests',
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAnnouncementsScreen())),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create New', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTypesCard() {
    final scheme = Theme.of(context).colorScheme;
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDocumentTypesScreen())),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.folder_copy_outlined, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Document Types', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 15)),
                    SizedBox(height: 6),
                    Text(
                      'Manage document fees, processing time, and requirements.',
                      style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text('View all', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Student Requests',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackRequestsScreen())),
              child: const Text('View all', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_recentRequests.isEmpty)
          const GlassContainer(
            padding: EdgeInsets.all(18),
            child: Text('No requests yet', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          )
        else
          ..._recentRequests.map((request) {
            final doc = (request['documentType'] ?? request['documentTypeName'] ?? 'Document').toString();
            final reference = (request['referenceNumber'] ?? 'REF-${request['id'] ?? ''}').toString();
            final status = (request['status'] ?? 'Pending').toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RequestListItem(
                title: doc,
                reference: reference,
                rawStatus: status,
              ),
            );
          }),
      ],
    );
  }

  String _formatCompactNumber(int value) {
    if (value >= 1000) {
      final asK = (value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1);
      return '${asK}k';
    }
    return value.toString();
  }
}

class _RequestListItem extends StatelessWidget {
  final String title;
  final String reference;
  final String rawStatus;

  const _RequestListItem({required this.title, required this.reference, required this.rawStatus});

  @override
  Widget build(BuildContext context) {
    final status = _statusConfig(rawStatus, Theme.of(context).colorScheme);
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(reference, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: status.color.withOpacity(0.25)),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(color: status.color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: status.progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE7E9F4),
                    valueColor: AlwaysStoppedAnimation<Color>(status.color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(status.progress * 100).round()}%',
                style: TextStyle(color: status.color, fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(status.subLabel, style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700, fontSize: 11)),
        ],
      ),
    );
  }

  _StatusView _statusConfig(String raw, ColorScheme scheme) {
    final s = raw.toLowerCase();
    if (s == 'download' || s == 'completed') {
      return const _StatusView(label: 'COMPLETED', subLabel: 'Completed', progress: 1.0, color: Color(0xFF7C3AED));
    }
    if (s == 'receive' || s == 'ready') {
      return const _StatusView(label: 'READY', subLabel: 'Ready for collection', progress: 0.9, color: Color(0xFF06B6D4));
    }
    if (s == 'approve' || s == 'approved') {
      return const _StatusView(label: 'APPROVED', subLabel: 'Approved', progress: 0.8, color: Color(0xFFEAB308));
    }
    if (s == 'inprocess' || s == 'in process' || s == 'processing') {
      return const _StatusView(label: 'IN PROCESS', subLabel: 'Current progress', progress: 0.65, color: Color(0xFFF59E0B));
    }
    if (s == 'rejected' || s == 'cancelled') {
      return const _StatusView(label: 'ARCHIVED', subLabel: 'Archived', progress: 1.0, color: Color(0xFF94A3B8));
    }
    return _StatusView(label: 'PENDING', subLabel: 'Queued', progress: 0.35, color: scheme.primary);
  }
}

class _StatusView {
  final String label;
  final String subLabel;
  final double progress;
  final Color color;

  const _StatusView({required this.label, required this.subLabel, required this.progress, required this.color});
}
