import 'dart:developer';
import 'package:dio/dio.dart';

class ApiService {
  // 10.0.2.2 is the special alias to your host loopback interface (i.e., 127.0.0.1 on your development machine)
  static const String _baseUrl = 'https://tts-server-0eos.onrender.com';

  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  /// Sends location update to backend and returns the JSON response
  Future<Map<String, dynamic>?> sendLocationUpdate(
    double latitude,
    double longitude,
  ) async {
    try {
      log('[ApiService] Sending location update: $latitude, $longitude');

      final response = await _dio.post(
        '/update-location',
        data: {'lat': latitude, 'lng': longitude},
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200) {
        log('[ApiService] Location update successful: ${response.data}');
        return response.data as Map<String, dynamic>;
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

  /// Fetches audio bytes from the provided URL
  Future<List<int>?> fetchAudio(String url) async {
    try {
      log('[ApiService] Fetching audio from: $url');
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        log(
          '[ApiService] Audio fetch successful. Received ${response.data.length} bytes.',
        );
        return response.data;
      } else {
        log(
          '[ApiService] Audio fetch failed with status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      log('[ApiService] Error fetching audio: $e');
      return null;
    }
  }
}
