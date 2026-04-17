import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import '../models/user_model.dart';
import '../widgets/notification_modal.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'track_requests_screen.dart';
import 'manage_announcements_screen.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/glassy_bottom_nav.dart';

class SuperAdminDashboard extends StatefulWidget {
  final UserModel user;

  const SuperAdminDashboard({super.key, required this.user});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _notificationCount = 0;
  bool _isLoading = true;
  final int _totalUsers = 0;
  int _totalRequests = 0;

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
          _totalRequests = requests.length;
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
                _buildSystemStats(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildSystemHealth(),
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
    return const GlassContainer(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SuperAdmin Dashboard',
            style: TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Full System Control & Monitoring',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Requests',
                  value: _isLoading ? '...' : '$_totalRequests',
                  icon: Icons.assignment_rounded,
                  color: Colors.blueAccent,
                  trend: '+5%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'System Users',
                  value: _isLoading ? '...' : '$_totalUsers',
                  icon: Icons.people_rounded,
                  color: Colors.greenAccent,
                  trend: '+12%',
                ),
              ),
            ],
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
          const Text('System Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _ActionCard(icon: Icons.campaign_rounded, title: 'Announcements', color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAnnouncementsScreen()))),
              _ActionCard(icon: Icons.admin_panel_settings_rounded, title: 'Manage Admins', color: Colors.deepPurple, onTap: () => _showComingSoon(context, 'Admin Management')),
              _ActionCard(icon: Icons.people_rounded, title: 'All Users', color: Colors.blue, onTap: () => _showComingSoon(context, 'User Directory')),
              _ActionCard(icon: Icons.security_rounded, title: 'Security', color: Colors.redAccent, onTap: () => _showComingSoon(context, 'Security Settings')),
              _ActionCard(icon: Icons.storage_rounded, title: 'Database', color: Colors.teal, onTap: () => _showComingSoon(context, 'Database Management')),
              _ActionCard(icon: Icons.backup_rounded, title: 'Backups', color: Colors.green, onTap: () => _showComingSoon(context, 'Backup System')),
              _ActionCard(icon: Icons.history_rounded, title: 'System Logs', color: Colors.orange, onTap: () => _showComingSoon(context, 'System Logs')),
              _ActionCard(icon: Icons.analytics_rounded, title: 'Analytics', color: Colors.cyan, onTap: () => _showComingSoon(context, 'System Analytics')),
              _ActionCard(icon: Icons.logout_rounded, title: 'Logout', color: Colors.redAccent, onTap: _handleLogout),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealth() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Health', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          SizedBox(height: 16),
          _HealthCard(title: 'API Server', status: 'Operational', statusColor: Colors.greenAccent, uptime: '99.9% uptime'),
          SizedBox(height: 12),
          _HealthCard(title: 'Database Cloud', status: 'Operational', statusColor: Colors.greenAccent, uptime: '99.8% uptime'),
          SizedBox(height: 12),
          _HealthCard(title: 'Static Storage', status: 'Optimizing', statusColor: Colors.orangeAccent, uptime: '85% capacity'),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature feature coming soon')));
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
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color, required this.trend});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(trend, style: const TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
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

  const _ActionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFF0F172A), fontWeight: FontWeight.w700), maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final String uptime;

  const _HealthCard({required this.title, required this.status, required this.statusColor, required this.uptime});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: statusColor.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)])),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                Text(uptime, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
          Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}
