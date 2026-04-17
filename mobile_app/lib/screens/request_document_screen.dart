import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_container.dart';


class RequestDocumentScreen extends StatefulWidget {
  const RequestDocumentScreen({super.key});

  @override
  State<RequestDocumentScreen> createState() => _RequestDocumentScreenState();
}

class _RequestDocumentScreenState extends State<RequestDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDocument;
  int? _selectedDocumentTypeId;
  final _purposeController = TextEditingController();
  final _copiesController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  List<dynamic> _documentTypes = [];

  @override
  void initState() {
    super.initState();
    _loadDocumentTypes();
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _copiesController.dispose();
    _notesController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _loadDocumentTypes() async {
    try {
      final types = await ApiService.getDocumentTypes();
      if (mounted) {
        setState(() {
          _documentTypes = types;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _documentTypes = [
            {'id': 1, 'name': 'Transcript of Records'},
            {'id': 2, 'name': 'Certificate of Grades'},
            {'id': 3, 'name': 'Certificate of Enrollment'},
            {'id': 4, 'name': 'Certificate of Good Moral'},
            {'id': 5, 'name': 'Diploma'},
            {'id': 6, 'name': 'Honorable Dismissal'},
            {'id': 7, 'name': 'Informative Copy of Grades'},
            
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedDocumentTypeId,
                          decoration: const InputDecoration(
                            labelText: 'Document Type',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          items: _documentTypes
                              .map((doc) => DropdownMenuItem<int>(
                                    value: doc['id'],
                                    child: Text(doc['name'] ?? 'Unknown'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDocumentTypeId = value;
                              _selectedDocument = _documentTypes
                                  .firstWhere((doc) => doc['id'] == value)['name'];
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a document' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _copiesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Number of Copies',
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            if (int.tryParse(value!) == null) return 'Invalid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _purposeController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Purpose',
                            prefixIcon: Icon(Icons.edit_note),
                            hintText: 'Enter the purpose of your request',
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Additional Notes (Optional)',
                            prefixIcon: Icon(Icons.note_add_outlined),
                            hintText: 'Any special instructions or details',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Processing time: 3-5 business days',
                            style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 55,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isLoading,
                      builder: (context, loading, _) {
                        return FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: loading ? null : _submitRequest,
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) throw Exception('User session not found');

      final requestData = {
        'userId': user.id,
        'documentTypeId': _selectedDocumentTypeId,
        'purpose': _purposeController.text.trim(),
        'quantity': int.parse(_copiesController.text),
        'notes': _notesController.text.trim(),
      };

      final result = await ApiService.createDocumentRequest(requestData);

      if (!mounted) return;

      if (result['success']) {
        _showSuccessDialog(result['data']?['referenceNumber']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to submit request'), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  void _showSuccessDialog([String? referenceNumber]) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) => Center(
        child: GlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Request Submitted',
                style: TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your document request has been received.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE7E9F4)),
                ),
                child: Column(
                  children: [
                    Container(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('REFERENCE NUMBER', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, letterSpacing: 1.2), textAlign: .end),
                    )),
                    const SizedBox(height: 8),
                    Text(
                      referenceNumber ?? 'REG-${DateTime.now().year}-${DateTime.now().millisecond}',
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to dashboard
                  },
                  child: const Text('Back to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
