import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/glass_container.dart';
import '../screens/track_requests_screen.dart';

class NotificationModal extends StatefulWidget {
  const NotificationModal({super.key});

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final announcements = await ApiService.getAnnouncements();
      List<dynamic> allNotifications = List.from(announcements);

      final user = await AuthService.getCurrentUser();
      if (user != null) {
        final requests = await ApiService.getDocumentRequestsByUserId(user.id ?? 0);
        
        // Turn actionable request updates into "notifications"
        for (var request in requests) {
          String rawStatus = request['status'] ?? 'Pending';
          String lower = rawStatus.toLowerCase();
          if (lower != 'request' && lower != 'pending') {
            
            // Map the document type
            final docTypeId = request['documentTypeId'];
            String docName = request['documentType'] ?? 'Document';
            if (docTypeId != null) {
              docName = await ApiService.getDocumentTypeName(docTypeId);
              request['documentTypeName'] = docName;
            }

            allNotifications.add({
              'isRequestUpdate': true,
              'requestData': request,
              'title': 'Request Updated: $docName',
              'body': 'Your request status has moved to $rawStatus.',
              'createdAt': request['updatedAt'] ?? request['requestDate'],
            });
          }
        }
      }

      final prefs = await AuthService.getPrefsInstance();
      final String? clearedTimeStr = prefs.getString('lastClearedNotificationsTime');
      DateTime? clearedTime = clearedTimeStr != null ? DateTime.tryParse(clearedTimeStr) : null;

      if (clearedTime != null) {
        allNotifications.removeWhere((n) {
          DateTime dt = DateTime.tryParse(n['createdAt']?.toString() ?? '') ?? DateTime.now();
          return !dt.isAfter(clearedTime);
        });
      }

      // Sort globally by date
      allNotifications.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.now();
        DateTime dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _notifications = allNotifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: const Color(0xFFE7E9F4)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_isLoading && _notifications.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        setState(() => _notifications = []);
                        final prefs = await AuthService.getPrefsInstance();
                        await prefs.setString('lastClearedNotificationsTime', DateTime.now().toIso8601String());
                      },
                      child: Text('Clear All', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            final bool isRequestUpdate = notification['isRequestUpdate'] == true;

                            return _NotificationCard(
                              title: notification['title'] ?? 'Update',
                              body: notification['body'] ?? '',
                              time: _formatDate(notification['createdAt']),
                              isRead: index > 2,
                              onTap: isRequestUpdate 
                                ? () => _openRequestDetails(context, notification['requestData'])
                                : null,
                            );
                          },
                        ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'All caught up!',
            style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'No new notifications for you right now.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Just now';
    try {
      final dateTime = DateTime.parse(date.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return DateFormat('MMM dd').format(dateTime);
    } catch (e) {
      return 'Today';
    }
  }

  void _openRequestDetails(BuildContext context, Map<String, dynamic> requestData) async {
    final user = await AuthService.getCurrentUser();
    String rawStatus = requestData['status'] ?? 'Pending';
    
    // Map status locally for the dialog
    RequestStatus statusEnum = RequestStatus.request;
    switch (rawStatus.toLowerCase()) {
      case 'inprocess':
      case 'in process':
      case 'processing':
        statusEnum = RequestStatus.inProcess;
        break;
      case 'approve':
      case 'approved':
        statusEnum = RequestStatus.approved;
        break;
      case 'receive':
      case 'ready':
        statusEnum = RequestStatus.receive;
        break;
      case 'download':
      case 'completed':
        statusEnum = RequestStatus.download;
        break;
    }

    if (!context.mounted) return;
    
    showRequestDetailsDialog(
      context: context,
      requestId: requestData['id'] ?? 0,
      referenceNumber: requestData['referenceNumber'] ?? 'REF-${requestData['id']}',
      documentType: requestData['documentTypeName'] ?? 'Document',
      status: statusEnum,
      rawStatus: rawStatus,
      date: DateTime.tryParse(requestData['requestDate'] ?? '') ?? DateTime.now(),
      copies: requestData['copies'] ?? 1,
      requestName: requestData['userName'] ?? user?.firstName ?? 'Unknown',
      purpose: requestData['purpose'] ?? 'No purpose provided',
      userRole: user?.role.name.toLowerCase() ?? 'student',
      onStatusUpdate: () => _loadNotifications(), // Refresh notifications
      documentUrl: requestData['documentUrl']?.toString() ?? '',
      currentRequest: Map<String, dynamic>.from(requestData),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: isRead ? Colors.transparent : scheme.primary,
              shape: BoxShape.circle,
              boxShadow: isRead 
                ? null 
                : [BoxShadow(color: scheme.primary.withOpacity(0.35), blurRadius: 6, spreadRadius: 0)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isRead ? const Color(0xFF475569) : const Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: isRead ? FontWeight.w700 : FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
