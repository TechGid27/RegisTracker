import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;
import '../models/user_model.dart';
import '../widgets/notification_modal.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'track_requests_screen.dart';
import 'announcements_screen.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/glassy_bottom_nav.dart';

class StaffDashboard extends StatefulWidget {
  final UserModel user;

  const StaffDashboard({super.key, required this.user});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _notificationCount = 0;
  bool _isLoading = true;
  int _pendingCount = 0;
  int _processingCount = 0;
  int _completedCount = 0;
  List<dynamic> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        ApiService.getDocumentRequests(),
        ApiService.getAnnouncements(),
        AuthService.getPrefsInstance().then((p) => p.getString('lastClearedNotificationsTime')),
      ]);
      final requests = results[0] as List<dynamic>;
      final announcements = results[1] as List<dynamic>;
      final clearedTimeStr = results[2] as String?;
      final clearedTime = clearedTimeStr != null ? DateTime.tryParse(clearedTimeStr) : null;

      int unreadCount = 0;
      for (var a in announcements) {
        final dt = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.now();
        if (clearedTime == null || dt.isAfter(clearedTime)) unreadCount++;
      }

      if (mounted) {
        setState(() {
          _pendingCount = requests.where((r) => r['status']?.toLowerCase() == 'request' || r['status']?.toLowerCase() == 'pending').length;
          _processingCount = requests.where((r) => r['status']?.toLowerCase() == 'in process' || r['status']?.toLowerCase() == 'processing').length;
          _completedCount = requests.where((r) => r['status']?.toLowerCase() == 'completed' || r['status']?.toLowerCase() == 'approved').length;
          _pendingRequests = requests.where((r) => r['status']?.toLowerCase() == 'request' || r['status']?.toLowerCase() == 'pending').take(3).toList();
          _notificationCount = unreadCount;
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
      extendBody: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              'Welcome, ${widget.user.firstName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          badges.Badge(
            badgeContent: Text(
              '$_notificationCount',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
            ),
            showBadge: _notificationCount > 0,
            position: badges.BadgePosition.topEnd(top: 8, end: 8),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _showNotifications(context),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100, top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStats(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildPendingRequests(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: GlassyBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackRequestsScreen()));
          } else if (index == 2) {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Staff Dashboard',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Department: ${widget.user.department ?? 'Registrar Office'}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Pending',
              value: _isLoading ? '...' : '$_pendingCount',
              icon: Icons.pending_actions_rounded,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Processing',
              value: _isLoading ? '...' : '$_processingCount',
              icon: Icons.autorenew_rounded,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Done',
              value: _isLoading ? '...' : '$_completedCount',
              icon: Icons.check_circle_outline_rounded,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _ActionCard(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Review Requests',
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrackRequestsScreen()),
                ),
              ),
              _ActionCard(
                icon: Icons.campaign_rounded,
                title: 'View Announcements',
                color: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                ),
              ),
              _ActionCard(
                icon: Icons.search_rounded,
                title: 'Search Files',
                color: Colors.teal,
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Search feature coming soon')));
                },
              ),
              _ActionCard(
                icon: Icons.logout_rounded,
                title: 'Logout',
                color: Colors.redAccent,
                onTap: _handleLogout,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPendingRequests() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pending Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackRequestsScreen())),
                child: const Text('View All', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_pendingRequests.isEmpty)
            const GlassContainer(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No pending requests found', style: TextStyle(color: Color(0xFF64748B))),
              ),
            )
          else
            ...(_pendingRequests.map((request) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RequestCard(
                  studentName: request['studentName'] ?? 'Student',
                  documentType: request['documentType'] ?? 'Document',
                  requestDate: _formatDate(request['requestDate']),
                ),
              );
            }).toList()),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationModal(),
    ).then((_) {
      if (mounted) _loadDashboardData();
    });
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container( // 👈 ensures layout inside Grid
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
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
}

class _RequestCard extends StatelessWidget {
  final String studentName;
  final String documentType;
  final String requestDate;

  const _RequestCard({
    required this.studentName,
    required this.documentType,
    required this.requestDate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox( // 👈 FIX layout issue
      width: double.infinity,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                studentName.isNotEmpty ? studentName[0] : 'S',
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    documentType,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              requestDate,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
