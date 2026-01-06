import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://propel.hoomaservice.com';
  static const Duration timeout = Duration(seconds: 15);

  // Common headers
  static Future<Map<String, String>> get headers async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic POST request
  static Future<Map<String, dynamic>?> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
  }) async {
    try {
      final headersMap = await headers;
      if (!requireAuth) headersMap.remove('Authorization');

      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headersMap,
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        return json.decode(response.body);
      } else {
        return {
          'status': false,
          'message': 'API server is not available. Please try again later.',
          'code': 503,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Network error. Please check your connection.',
        'code': 0,
      };
    }
  }

  // Generic PUT request
  static Future<Map<String, dynamic>?> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: await headers,
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        return json.decode(response.body);
      } else {
        return {
          'status': false,
          'message': 'API server is not available. Please try again later.',
          'code': 503,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Network error. Please check your connection.',
        'code': 0,
      };
    }
  }

  // Generic GET request with query parameters
  static Future<Map<String, dynamic>?> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: await headers)
          .timeout(timeout);

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        return json.decode(response.body);
      } else {
        return {
          'status': false,
          'message': 'API server is not available. Please try again later.',
          'code': 503,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Network error. Please check your connection.',
        'code': 0,
      };
    }
  }

  // Multipart POST request for file uploads
  static Future<Map<String, dynamic>?> multipartPost(
    String endpoint,
    Map<String, String> fields, {
    List<http.MultipartFile>? files,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(await headers);
      request.fields.addAll(fields);
      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        return json.decode(response.body);
      } else {
        return {
          'status': false,
          'message': 'API server is not available. Please try again later.',
          'code': 503,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Network error. Please check your connection.',
        'code': 0,
      };
    }
  }

  // Generic DELETE request
  static Future<Map<String, dynamic>?> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: await headers)
          .timeout(timeout);

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        return json.decode(response.body);
      } else {
        return {
          'status': false,
          'message': 'API server is not available. Please try again later.',
          'code': 503,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Network error. Please check your connection.',
        'code': 0,
      };
    }
  }
}
