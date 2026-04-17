import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/announcements_screen.dart';
import '../screens/document_types_screen.dart';
import '../screens/settings_screen.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/notification_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: GradientBackground(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 20),
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                          child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.primary),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _user?.fullName ?? 'User Name',
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.email ?? 'email@example.com',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    if (_user?.studentId != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE7E9F4))),
                        child: Text(
                          'ID: ${_user!.studentId}',
                          style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _ProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () => _showNotifications(context),
              ),
              _ProfileMenuItem(
                icon: Icons.folder_copy_outlined,
                title: 'Document Types & Fees',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentTypesScreen())),
              ),
              _ProfileMenuItem(
                icon: Icons.campaign_outlined,
                title: 'Announcements',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
                },
              ),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              const SizedBox(height: 20),
              _ProfileMenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                textColor: Colors.redAccent,
                onTap: () => _showLogoutDialog(context),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationModal(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) => Center(
        child: GlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Logout', style: TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Are you sure you want to sign out of your account?', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await AuthService.logout();
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                      },
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.8)),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textColor;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.icon, required this.title, this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = textColor ?? const Color(0xFF0F172A);
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: effectiveColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: effectiveColor, size: 20),
        ),
        title: Text(title, style: TextStyle(color: effectiveColor, fontSize: 16, fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
