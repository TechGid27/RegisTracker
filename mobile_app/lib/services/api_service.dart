import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_config.dart';
import 'auth_service.dart';

class ApiService {
  // Singleton HTTP client — avoids creating a new client per request
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 15);

  // Simple in-memory cache for rarely-changing data
  static List<dynamic>? _documentTypesCache;
  static DateTime? _documentTypesCachedAt;
  static const Duration _cacheTtl = Duration(minutes: 5);

  static bool _isCacheValid(DateTime? cachedAt) =>
      cachedAt != null && DateTime.now().difference(cachedAt) < _cacheTtl;

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Offload JSON decoding to isolate for large payloads
  static Future<dynamic> _decodeJson(String body) async {
    if (body.length > 10000) {
      return compute(jsonDecode, body);
    }
    return jsonDecode(body);
  }

  // Authentication
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = await _decodeJson(response.body);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
          'expiresAt': data['expiresAt'],
        };
      } else {
        final body = json.decode(response.body);
        return {'success': false, 'message': body['message'] ?? 'Login failed'};
      }
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(userData),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'user': await _decodeJson(response.body)};
      } else {
        final body = json.decode(response.body);
        return {'success': false, 'message': body['message'] ?? 'Registration failed'};
      }
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyEmail(String email, String otp) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}/verify-email'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'otp': otp}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        final body = response.body.isNotEmpty ? json.decode(response.body) : {};
        return {'success': false, 'message': body['message'] ?? 'Verification failed'};
      }
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}/resend-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        final body = response.body.isNotEmpty ? json.decode(response.body) : {};
        return {'success': false, 'message': body['message'] ?? 'Failed to resend OTP'};
      }
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Users
  static Future<List<dynamic>> getUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}'), headers: headers)
          .timeout(_timeout);
      if (response.statusCode == 200) return await _decodeJson(response.body);
      return [];
    } on TimeoutException {
      return [];
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/$id'), headers: headers)
          .timeout(_timeout);
      if (response.statusCode == 200) return await _decodeJson(response.body);
      return null;
    } on TimeoutException {
      return null;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .put(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/$id'),
            headers: headers,
            body: json.encode(userData),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        return {'success': true, 'user': await _decodeJson(response.body)};
      }
      return {'success': false, 'message': 'Failed to update user'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(int userId, String currentPassword, String newPassword) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}/change-password'),
            headers: headers,
            body: json.encode({
              'userId': userId,
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      final body = response.body.isNotEmpty ? json.decode(response.body) : {};
      return {'success': false, 'message': body['message'] ?? 'Failed to change password'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<bool> deleteUser(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .delete(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/$id'), headers: headers)
          .timeout(_timeout);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  // Document Requests
  static Future<List<dynamic>> getDocumentRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentRequests}'), headers: headers)
          .timeout(_timeout);
      if (response.statusCode == 200) return await _decodeJson(response.body);
      return [];
    } on TimeoutException {
      return [];
    } catch (e) {
      debugPrint('Error fetching document requests: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getDocumentRequestsByUserId(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentRequests}/user/$userId'),
            headers: headers,
          )
          .timeout(_timeout);
      if (response.statusCode == 200) return await _decodeJson(response.body);
      return [];
    } on TimeoutException {
      return [];
    } catch (e) {
      debugPrint('Error fetching user document requests: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getDocumentRequestById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentRequests}/$id'),
            headers: headers,
          )
          .timeout(_timeout);
      if (response.statusCode == 200) return await _decodeJson(response.body);
      return null;
    } on TimeoutException {
      return null;
    } catch (e) {
      debugPrint('Error fetching document request: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getDocumentRequestByReference(String referenceNumber) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentRequests}/reference/$referenceNumber'),
            headers: headers,
          )
          .timeout(_timeout);
      if (response.statusCode == 200) return await _decodeJson(response.body);
      return null;
    } on TimeoutException {
      return null;
    } catch (e) {
      debugPrint('Error fetching document request by reference: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> createDocumentRequest(Map<String, dynamic> requestData) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentRequests}'),
            headers: headers,
            body: json.encode(requestData),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': await _decodeJson(response.body)};
      }
      return {'success': false, 'message': 'Failed to create request'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadDocument(int id, String filename, List<int> bytes) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentRequests}/$id/upload'),
      );

      if (headers.containsKey('Authorization')) {
        request.headers['Authorization'] = headers['Authorization']!;
      }

      String ext = filename.split('.').last.toLowerCase();
      MediaType mediaType;
      if (ext == 'pdf') {
        mediaType = MediaType('application', 'pdf');
      } else if (ext == 'jpg' || ext == 'jpeg') {
        mediaType = MediaType('image', 'jpeg');
      } else if (ext == 'png') {
        mediaType = MediaType('image', 'png');
      } else {
        mediaType = MediaType('application', 'octet-stream');
      }

      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename, contentType: mediaType));

      final streamedResponse = await request.send().timeout(_timeout);
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        return {'success': true, 'data': json.decode(responseBody)};
      }
      return {'success': false, 'message': 'Failed to upload document'};
    } on TimeoutException {
      return {'success': false, 'message': 'Upload timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateDocumentRequest(int id, Map<String, dynamic> requestData) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .put(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentRequests}/$id'),
            headers: headers,
            body: json.encode(requestData),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          return {'success': true, 'data': await _decodeJson(response.body)};
        }
        return {'success': true};
      }
      return {'success': false, 'message': 'Failed to update request'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<bool> deleteDocumentRequest(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .delete(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentRequests}/$id'),
            headers: headers,
          )
          .timeout(_timeout);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting document request: $e');
      return false;
    }
  }

  // Document Types — cached to avoid repeated network calls
  static Future<List<dynamic>> getDocumentTypes() async {
    if (_isCacheValid(_documentTypesCachedAt) && _documentTypesCache != null) {
      return _documentTypesCache!;
    }
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentTypes}'), headers: headers)
          .timeout(_timeout);
      if (response.statusCode == 200) {
        _documentTypesCache = await _decodeJson(response.body);
        _documentTypesCachedAt = DateTime.now();
        return _documentTypesCache!;
      }
      return [];
    } on TimeoutException {
      return [];
    } catch (e) {
      debugPrint('Error fetching document types: $e');
      return [];
    }
  }

  // Uses cache — no extra network call per item
  static Future<String> getDocumentTypeName(int id) async {
    try {
      final types = await getDocumentTypes();
      final match = types.firstWhere((t) => t['id'] == id, orElse: () => null);
      return match?['name'] ?? 'Unknown Document';
    } catch (e) {
      debugPrint('Error fetching document type name: $e');
      return 'Unknown Document';
    }
  }

  static void invalidateDocumentTypesCache() {
    _documentTypesCache = null;
    _documentTypesCachedAt = null;
  }

  static Future<Map<String, dynamic>> createDocumentType(Map<String, dynamic> typeData) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentTypes}'),
            headers: headers,
            body: json.encode(typeData),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        invalidateDocumentTypesCache();
        return {'success': true, 'data': await _decodeJson(response.body)};
      }
      return {'success': false, 'message': 'Failed to create document type'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateDocumentType(int id, Map<String, dynamic> typeData) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .put(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentTypes}/$id'),
            headers: headers,
            body: json.encode(typeData),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 204) {
        invalidateDocumentTypesCache();
        return {'success': true};
      }
      return {'success': false, 'message': 'Failed to update document type'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<bool> deleteDocumentType(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .delete(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentTypes}/$id'),
            headers: headers,
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 204) {
        invalidateDocumentTypesCache();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting document type: $e');
      return false;
    }
  }

  // Document Requirements
  static Future<List<dynamic>> getDocumentRequirements() async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentRequirements}'), headers: headers)
          .timeout(_timeout);
      if (response.statusCode == 200) return await _decodeJson(response.body);
      return [];
    } on TimeoutException {
      return [];
    } catch (e) {
      debugPrint('Error fetching document requirements: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getDocumentRequirementsByTypeId(int typeId) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documentRequirements}/type/$typeId'),
            headers: headers,
          )
          .timeout(_timeout);
      if (response.statusCode == 200) return await _decodeJson(response.body);
      return [];
    } on TimeoutException {
      return [];
    } catch (e) {
      debugPrint('Error fetching document requirements by type: $e');
      return [];
    }
  }

  // Announcements
  static Future<List<dynamic>> getAnnouncements() async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcements}'), headers: headers)
          .timeout(_timeout);
      if (response.statusCode == 200) return await _decodeJson(response.body);
      return [];
    } on TimeoutException {
      return [];
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getAnnouncementById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcements}/$id'), headers: headers)
          .timeout(_timeout);
      if (response.statusCode == 200) return await _decodeJson(response.body);
      return null;
    } on TimeoutException {
      return null;
    } catch (e) {
      debugPrint('Error fetching announcement: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> createAnnouncement(Map<String, dynamic> announcementData) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcements}'),
            headers: headers,
            body: json.encode(announcementData),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': await _decodeJson(response.body)};
      }
      return {'success': false, 'message': 'Failed to create announcement'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateAnnouncement(int id, Map<String, dynamic> announcementData) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .put(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcements}/$id'),
            headers: headers,
            body: json.encode(announcementData),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          return {'success': true, 'data': await _decodeJson(response.body)};
        }
        return {'success': true};
      }
      return {'success': false, 'message': 'Failed to update announcement'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<bool> deleteAnnouncement(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .delete(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.announcements}/$id'), headers: headers)
          .timeout(_timeout);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
      return false;
    }
  }

  // Dashboard stats — all 3 requests run in parallel
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final results = await Future.wait([
        getDocumentRequests(),
        getUsers(),
        getAnnouncements(),
      ]);

      final requests = results[0];
      final users = results[1];
      final announcements = results[2];

      return {
        'totalRequests': requests.length,
        'totalUsers': users.length,
        'totalAnnouncements': announcements.length,
        'pendingRequests': requests.where((r) {
          final s = r['status']?.toLowerCase();
          return s == 'request' || s == 'pending';
        }).length,
        'processingRequests': requests.where((r) {
          final s = r['status']?.toLowerCase();
          return s == 'in process' || s == 'processing';
        }).length,
        'completedRequests': requests.where((r) {
          final s = r['status']?.toLowerCase();
          return s == 'completed' || s == 'approved';
        }).length,
      };
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      return {};
    }
  }
}
