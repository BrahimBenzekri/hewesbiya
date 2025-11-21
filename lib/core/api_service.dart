import 'dart:developer';
import 'package:dio/dio.dart';

class ApiService {
  // 10.0.2.2 is the special alias to your host loopback interface (i.e., 127.0.0.1 on your development machine)
  static const String _baseUrl = 'http://10.0.2.2:3000';

  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  /// Sends location update to backend and returns audio file bytes if successful
  Future<List<int>?> sendLocationUpdate(
    double latitude,
    double longitude,
  ) async {
    try {
      log('[ApiService] Sending location update: $latitude, $longitude');

      final response = await _dio.post(
        '/update-location',
        data: {'lat': latitude, 'lng': longitude},
      );

      if (response.statusCode == 200) {
        log(
          '[ApiService] Location update successful. Received ${response.data.length} bytes.',
        );
        return response.data;
      } else {
        log(
          '[ApiService] Location update failed with status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      log('[ApiService] Error sending location update: $e');
      return null;
    }
  }
}
