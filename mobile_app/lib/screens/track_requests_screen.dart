import 'dart:async';
import 'dart:ui';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';
import '../services/api_config.dart';

class TrackRequestsScreen extends StatefulWidget {
  const TrackRequestsScreen({super.key});

  @override
  State<TrackRequestsScreen> createState() => _TrackRequestsScreenState();
}

class _TrackRequestsScreenState extends State<TrackRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _userRole = 'student';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    
    // Poll every 30s instead of 5s — reduces server load and UI jank significantly
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadRequests(showLoading: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRequests({bool showLoading = true}) async {
    if (!mounted) return;
    if (showLoading) setState(() => _isLoading = true);

    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        _userRole = user.role.name.toLowerCase();
        final requests = _userRole == 'student'
            ? await ApiService.getDocumentRequestsByUserId(user.id ?? 0)
            : await ApiService.getDocumentRequests();

        Map<int, String> cache = {};
        List<dynamic> updatedRequests = [];

        for (var request in requests) {
          final docTypeId = request['documentTypeId'];
          String docName = request['documentType'] ?? 'Unknown Document';

          if (docTypeId != null) {
            if (cache.containsKey(docTypeId)) {
              docName = cache[docTypeId]!;
            } else {
              docName = await ApiService.getDocumentTypeName(docTypeId);
              cache[docTypeId] = docName;
            }
          }

          updatedRequests.add({...request, 'documentTypeName': docName});
        }

        if (mounted) {
          setState(() {
            _requests = updatedRequests;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadRequests(showLoading: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 80,
                        color: Colors.black.withOpacity(0.12),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No requests found',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: () => _loadRequests(showLoading: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return _RequestCard(
                        requestId: request['id'] ?? 0,
                        referenceNumber:
                            request['referenceNumber'] ??
                            'REF-${request['id']}',
                        documentType:
                            request['documentTypeName'] ?? 'Unknown Document',
                        status: _mapStatus(request['status'] ?? 'Request'),
                        rawStatus: request['status'] ?? 'Pending',
                        date:
                            DateTime.tryParse(request['requestDate'] ?? '') ??
                            DateTime.now(),
                        copies: request['copies'] ?? 1,
                        purpose: request['purpose'] ?? 'No purpose provided',
                        requestName: request['userName'] ?? 'Unknown',
                        userRole: _userRole,
                        onStatusUpdate: _loadRequests,
                        documentUrl: request['documentUrl']?.toString() ?? '',
                        currentRequest: Map<String, dynamic>.from(request as Map),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  RequestStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'request':
      case 'pending':
        return RequestStatus.request;
      case 'inprocess':
      case 'in process':
      case 'processing':
        return RequestStatus.inProcess;
      case 'approve':
      case 'approved':
        return RequestStatus.approved;
      case 'receive':
      case 'ready':
        return RequestStatus.receive;
      case 'download':
      case 'completed':
        return RequestStatus.download;
      default:
        return RequestStatus.request;
    }
  }
}

enum RequestStatus { request, inProcess, approved, receive, download }

class _RequestCard extends StatelessWidget {
  final int requestId;
  final String referenceNumber;
  final String documentType;
  final RequestStatus status;
  final String rawStatus;
  final DateTime date;
  final int copies;
  final String requestName;
  final String purpose;
  final String userRole;
  final VoidCallback onStatusUpdate;
  final String documentUrl;
  final Map<String, dynamic> currentRequest;

  const _RequestCard({
    required this.requestId,
    required this.referenceNumber,
    required this.documentType,
    required this.status,
    required this.rawStatus,
    required this.date,
    required this.copies,
    required this.requestName,
    required this.purpose,
    required this.userRole,
    required this.onStatusUpdate,
    required this.documentUrl,
    required this.currentRequest,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => showRequestDetailsDialog(
          context: context,
          requestId: requestId,
          referenceNumber: referenceNumber,
          documentType: documentType,
          status: status,
          rawStatus: rawStatus,
          date: date,
          copies: copies,
          requestName: requestName,
          purpose: purpose,
          userRole: userRole,
          onStatusUpdate: onStatusUpdate,
          documentUrl: documentUrl,
          currentRequest: currentRequest,
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    referenceNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  _StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                documentType,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd, yyyy').format(date),
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$copies copies',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.account_box_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  if (userRole == 'student')
                    const Text(
                      'Requested by: Me',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    )
                  else
                    Text(
                      'Requested by: $requestName',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
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

void showRequestDetailsDialog({
  required BuildContext context,
  required int requestId,
  required String referenceNumber,
  required String documentType,
  required RequestStatus status,
  required String rawStatus,
  required DateTime date,
  required int copies,
  required String requestName,
  required String purpose,
  required String userRole,
  required VoidCallback onStatusUpdate,
  required String documentUrl,
  required Map<String, dynamic> currentRequest,
}) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Details',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _DetailRow(label: 'Reference', value: referenceNumber),
                      _DetailRow(label: 'Document', value: documentType),
                      _DetailRow(
                        label: 'Request Date',
                        value: DateFormat('MMMM dd, yyyy').format(date),
                      ),
                      _DetailRow(
                        label: 'Number of Copies',
                        value: copies.toString(),
                      ),
                      _DetailRow(label: 'Purpose', value: purpose),
                      if (userRole == 'admin' || userRole == 'staff') ...[
                        const SizedBox(height: 32),
                        const Text(
                          'Update Status (Admin/Staff Action)',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _UpdateStatusWidget(
                          requestId: requestId,
                          currentStatus: rawStatus,
                          currentRequest: currentRequest,
                          onUpdate: () {
                            Navigator.pop(context);
                            onStatusUpdate();
                          },
                        ),
                      ],
                      const SizedBox(height: 48),
                      const Text(
                        'Track Progress',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _StatusTimeline(currentStatus: status),
                      const SizedBox(height: 40),
                      if (status == RequestStatus.download && documentUrl.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(                   
                            onPressed: () {
                                const baseUrl = ApiConfig.baseUrl2;

                                final fullUrl = documentUrl.startsWith('http')
                                    ? documentUrl
                                    : "$baseUrl$documentUrl";

                                final anchor = html.AnchorElement(href: fullUrl)
                                ..setAttribute("download", "") // forces download
                                ..click();
                              },
                              icon: const Icon(Icons.download_rounded),
                              label: const Text('Download Document'),
                              style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        )
                      else if (status == RequestStatus.download && documentUrl.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withOpacity(0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Document not yet uploaded by admin.',
                                  style: TextStyle(color: Colors.orange, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

class _StatusChip extends StatelessWidget {
  final RequestStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (config['color'] as Color).withOpacity(0.3)),
      ),
      child: Text(
        config['label'],
        style: TextStyle(
          color: config['color'],
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (status) {
      case RequestStatus.request:
        return {'label': 'PENDING', 'color': Colors.blueAccent};
      case RequestStatus.inProcess:
        return {'label': 'PROCESSING', 'color': Colors.orangeAccent};
      case RequestStatus.approved:
        return {'label': 'APPROVED', 'color': Colors.greenAccent};
      case RequestStatus.receive:
        return {'label': 'READY', 'color': Colors.cyanAccent};
      case RequestStatus.download:
        return {'label': 'COMPLETED', 'color': Colors.purpleAccent};
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final RequestStatus currentStatus;
  const _StatusTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final statuses = RequestStatus.values;
    return Column(
      children: statuses.map((status) {
        final isCompleted = status.index <= currentStatus.index;
        final isActive = status == currentStatus;
        final isLast = status == statuses.last;
        return _TimelineItem(
          status: status,
          isCompleted: isCompleted,
          isActive: isActive,
          isLast: isLast,
        );
      }).toList(),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final RequestStatus status;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;

  const _TimelineItem({
    required this.status,
    required this.isCompleted,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : const Color(0xFFF1F5FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? Theme.of(context).colorScheme.primary : const Color(0xFFE7E9F4),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 14)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Theme.of(context).colorScheme.primary : const Color(0xFFE7E9F4),
              ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontWeight: isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCompleted ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                ),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Current Status',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(RequestStatus status) {
    switch (status) {
      case RequestStatus.request:
        return 'Request Submitted';
      case RequestStatus.inProcess:
        return 'In Process';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.receive:
        return 'Ready for Collection';
      case RequestStatus.download:
        return 'Document Completed';
    }
  }
}

class _UpdateStatusWidget extends StatefulWidget {
  final int requestId;
  final String currentStatus;
  final Map<String, dynamic> currentRequest;
  final VoidCallback onUpdate;

  const _UpdateStatusWidget({
    required this.requestId,
    required this.currentStatus,
    required this.currentRequest,
    required this.onUpdate,
  });

  @override
  State<_UpdateStatusWidget> createState() => _UpdateStatusWidgetState();
}

class _UpdateStatusWidgetState extends State<_UpdateStatusWidget> {
  bool _isUpdating = false;
  late String _selectedStatus;
  PlatformFile? _selectedFile;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, String>> _statusOptions = [
    {'value': 'Request', 'label': 'Request Submitted'},
    {'value': 'InProcess', 'label': 'In Process'},
    {'value': 'Approve', 'label': 'Approved'},
    {'value': 'Receive', 'label': 'Ready for Collection'},
    {'value': 'Download', 'label': 'Document Completed'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    _notesController.text = widget.currentRequest['notes'] ?? '';
    bool isValid = _statusOptions.any((opt) => opt['value'] == _selectedStatus);
    
    if (!isValid) {
      String lower = _selectedStatus.toLowerCase();
      if (lower == 'request' || lower == 'pending') _selectedStatus = 'Request';
      else if (lower == 'inprocess' || lower == 'processing' || lower == 'in process') _selectedStatus = 'InProcess';
      else if (lower == 'approve' || lower == 'approved') _selectedStatus = 'Approve';
      else if (lower == 'receive' || lower == 'ready') _selectedStatus = 'Receive';
      else if (lower == 'download' || lower == 'completed') _selectedStatus = 'Download';
      else _selectedStatus = 'Request'; // Fallback
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == 'Approve' && _selectedFile == null && (widget.currentRequest['documentUrl'] == null || widget.currentRequest['documentUrl'].toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload for approval.')),
      );
      return;
    }

    setState(() => _isUpdating = true);

    String uploadedUrl = widget.currentRequest['documentUrl'] ?? '';
    if (_selectedFile != null && _selectedFile!.bytes != null) {
      final uploadResult = await ApiService.uploadDocument(
        widget.requestId,
        _selectedFile!.name,
        _selectedFile!.bytes!,
      );
      if (uploadResult['success']) {
        uploadedUrl = uploadResult['data']['documentUrl'];
      } else {
        if (mounted) {
          setState(() => _isUpdating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(uploadResult['message'] ?? 'Failed to upload file')),
          );
        }
        return;
      }
    }
    
    int userId = 0;
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      userId = user.id ?? 0;
    }

    final updatedData = {
      'status': _selectedStatus,
      'notes': _notesController.text.trim(),
      'documentUrl': uploadedUrl,
      'processedBy': userId,
      'approvedBy': userId,
    };
    
    final result = await ApiService.updateDocumentRequest(widget.requestId, updatedData);
    
    if (mounted) setState(() => _isUpdating = false);
    
    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
        widget.onUpdate();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to update status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E9F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w700),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                    items: _statusOptions.map((opt) {
                      return DropdownMenuItem(
                        value: opt['value'],
                        child: Text(opt['label']!),
                      );
                    }).toList(),
                    onChanged: _isUpdating ? null : (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _isUpdating ? null : _updateStatus,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isUpdating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Update'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Add notes here...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 2,
          ),
          if (_selectedStatus == 'Approve' || _selectedStatus == 'Receive' || _selectedStatus == 'Download') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedFile != null
                        ? 'Selected: ${_selectedFile!.name}'
                        : (widget.currentRequest['documentUrl'] != null && widget.currentRequest['documentUrl'].toString().isNotEmpty)
                            ? 'File already uploaded'
                            : 'Required: PDF/Image file',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isUpdating ? null : _pickFile,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Pick File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFE7E9F4)),
                  ),
                )
              ],
            ),
          ]
        ],
      ),
    );
  }
}
