import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'manage_announcements_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final _screens = [
    const AdminDashboardTab(),
    const AdminRequestsTab(),
    const AdminProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  bool _isLoading = true;
  List<dynamic> _requests = [];
  int _pendingCount = 0;
  int _processingCount = 0;
  int _approvedCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final requests = await ApiService.getDocumentRequests();
      if (!mounted) return;
      setState(() {
        _requests = requests.take(5).toList();
        _pendingCount = requests.where((r) => r['status']?.toLowerCase() == 'request' || r['status']?.toLowerCase() == 'pending').length;
        _processingCount = requests.where((r) => r['status']?.toLowerCase() == 'in process' || r['status']?.toLowerCase() == 'processing').length;
        _approvedCount = requests.where((r) => r['status']?.toLowerCase() == 'approved').length;
        _completedCount = requests.where((r) => r['status']?.toLowerCase() == 'completed').length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        title: 'Pending',
                        count: '$_pendingCount',
                        icon: Icons.pending_outlined,
                        color: Colors.orange,
                      ),
                      _StatCard(
                        title: 'In Process',
                        count: '$_processingCount',
                        icon: Icons.autorenew,
                        color: Colors.blue,
                      ),
                      _StatCard(
                        title: 'Approved',
                        count: '$_approvedCount',
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      _StatCard(
                        title: 'Completed',
                        count: '$_completedCount',
                        icon: Icons.done_all,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Requests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_requests.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No requests found')),
                      ),
                    )
                  else
                    ...(_requests.map((request) {
                      return _AdminRequestCard(
                        referenceNumber: request['referenceNumber'] ?? 'N/A',
                        studentName: request['studentName'] ?? 'Student',
                        documentType: request['documentType'] ?? 'Document',
                        status: request['status'] ?? 'Pending',
                        date: DateTime.tryParse(request['requestDate'] ?? '') ?? DateTime.now(),
                      );
                    }).toList()),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(
              count,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminRequestCard extends StatelessWidget {
  final String referenceNumber;
  final String studentName;
  final String documentType;
  final String status;
  final DateTime date;

  const _AdminRequestCard({
    required this.referenceNumber,
    required this.studentName,
    required this.documentType,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(studentName[0]),
        ),
        title: Text(referenceNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(studentName),
            Text(documentType, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Chip(
          label: Text(status, style: const TextStyle(fontSize: 11)),
          padding: EdgeInsets.zero,
        ),
        onTap: () {},
      ),
    );
  }
}

class AdminRequestsTab extends StatefulWidget {
  const AdminRequestsTab({super.key});

  @override
  State<AdminRequestsTab> createState() => _AdminRequestsTabState();
}

class _AdminRequestsTabState extends State<AdminRequestsTab> {
  bool _isLoading = true;
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final requests = await ApiService.getDocumentRequests();
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No requests found'))
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return _RequestManagementCard(
                        referenceNumber: request['referenceNumber'] ?? 'N/A',
                        studentName: request['studentName'] ?? 'Student',
                        studentId: request['studentId'] ?? 'N/A',
                        documentType: request['documentType'] ?? 'Document',
                        copies: request['copies'] ?? 1,
                        purpose: request['purpose'] ?? 'N/A',
                        status: request['status'] ?? 'Pending',
                        date: DateTime.tryParse(request['requestDate'] ?? '') ?? DateTime.now(),
                        requestId: request['id'],
                        onUpdate: _loadRequests,
                      );
                    },
                  ),
                ),
    );
  }
}

class _RequestManagementCard extends StatelessWidget {
  final String referenceNumber;
  final String studentName;
  final String studentId;
  final String documentType;
  final int copies;
  final String purpose;
  final String status;
  final DateTime date;
  final int? requestId;
  final VoidCallback? onUpdate;

  const _RequestManagementCard({
    required this.referenceNumber,
    required this.studentName,
    required this.studentId,
    required this.documentType,
    required this.copies,
    required this.purpose,
    required this.status,
    required this.date,
    this.requestId,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(studentName[0]),
        ),
        title: Text(referenceNumber),
        subtitle: Text('$studentName ($studentId)'),
        trailing: _StatusChip(status: status),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: 'Document', value: documentType),
                _DetailRow(label: 'Copies', value: copies.toString()),
                _DetailRow(label: 'Purpose', value: purpose),
                _DetailRow(
                    label: 'Date',
                    value: DateFormat('MMM dd, yyyy hh:mm a').format(date)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateStatus(context, 'In Process'),
                        icon: const Icon(Icons.autorenew, size: 18),
                        label: const Text('Process'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _updateStatus(context, 'Approved'),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    if (requestId == null) return;
    
    try {
      final result = await ApiService.updateDocumentRequest(requestId!, {
        'status': newStatus,
      });
      
      if (context.mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Request updated to $newStatus')),
          );
          onUpdate?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update request')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Pending':
        color = Colors.orange;
        break;
      case 'In Process':
        color = Colors.blue;
        break;
      case 'Approved':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.admin_panel_settings,
                        size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Administrator',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'admin@test.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.announcement_outlined,
            title: 'Manage Announcements',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageAnnouncementsScreen()),
              );
            },
          ),
          _ProfileMenuItem(
            icon: Icons.description_outlined,
            title: 'Document Requirements',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.analytics_outlined,
            title: 'Reports',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _ProfileMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textColor;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(
          title,
          style: TextStyle(color: textColor),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
