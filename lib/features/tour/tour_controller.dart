import 'dart:developer';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hewesbiya/core/location_service.dart';
import 'package:hewesbiya/core/api_service.dart';
import 'package:geolocator/geolocator.dart';

class TourController extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();
  
  String _locationName = "Locating...";
  bool _isLoading = true;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentCaption = "Initializing tour...";
  
  // Location Status
  bool _isLocationEnabled = false;
  bool _hasPermission = false;
  StreamSubscription<Position>? _positionSubscription;

  // Getters
  String get locationName => _locationName;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get currentCaption => _currentCaption;
  bool get isLocationReady => _isLocationEnabled && _hasPermission;

  Future<bool> checkLocationRequirements() async {
    log('[TourController] checkLocationRequirements() called');
    LocationPermissionStatus status = await _locationService.checkPermissionStatus();
    log('[TourController] Permission status: $status');
    
    _isLocationEnabled = status != LocationPermissionStatus.serviceDisabled;
    _hasPermission = status == LocationPermissionStatus.granted;
    
    if (status == LocationPermissionStatus.serviceDisabled) {
      log('[TourController] Location services disabled');
      _currentCaption = "Location services are disabled.";
      notifyListeners();
      return false;
    }

    if (status == LocationPermissionStatus.denied) {
      log('[TourController] Permission denied, requesting...');
      status = await _locationService.requestLocation();
      _hasPermission = status == LocationPermissionStatus.granted;
      
      if (status == LocationPermissionStatus.denied) {
        log('[TourController] Permission denied after request');
        _currentCaption = "Location permission denied.";
        notifyListeners();
        return false;
      }
    }
    
    if (status == LocationPermissionStatus.deniedForever) {
      log('[TourController] Permission denied forever');
      _currentCaption = "Location permission permanently denied.";
      notifyListeners();
      return false;
    }

    log('[TourController] Location requirements met');
    _hasPermission = true;
    notifyListeners();
    return true;
  }

  Future<void> loadTour() async {
    log('[TourController] loadTour() called');
    _isLoading = true;
    notifyListeners();
    
    // Check location first
    if (!await checkLocationRequirements()) {
      log('[TourController] Location requirements failed, aborting loadTour');
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      log('[TourController] Getting current position for initial update...');
      // Send immediate location update to trigger backend
      final position = await _locationService.getCurrentPosition();
      log('[TourController] Initial position: ${position.latitude}, ${position.longitude}');
      await _handleLocationUpdate(position);

      // Start tracking location
      _startLocationTracking();
      
    } catch (e) {
      log('[TourController] Error in loadTour: $e');
      _currentCaption = "Error connecting to tour service.";
      debugPrint("Error in loadTour: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startLocationTracking() {
    log('[TourController] Starting location tracking stream...');
    _positionSubscription?.cancel();
    _positionSubscription = _locationService.getPositionStream().listen((
      position,
    ) async {
      log('[TourController] Stream received position: ${position.latitude}, ${position.longitude}');
      await _handleLocationUpdate(position);
    });
  }

  DateTime? _lastRequestTime;

  Future<void> _handleLocationUpdate(Position position) async {
    log('[TourController] _handleLocationUpdate called with ${position.latitude}, ${position.longitude}');
    
    // Debounce: Prevent requests within 2 seconds of the last one
    if (_lastRequestTime != null && 
        DateTime.now().difference(_lastRequestTime!) < const Duration(seconds: 2)) {
      log('[TourController] Debounced: Skipping update (too soon)');
      return;
    }
    _lastRequestTime = DateTime.now();

    log('[TourController] Sending update to API...');
    final response = await _apiService.sendLocationUpdate(
      position.latitude, 
      position.longitude
    );
    
    if (response != null) {
      log('[TourController] API Response received: $response');
      if (response['inside'] == true) {
        log('[TourController] User is INSIDE');
        _locationName = response['locationName'] ?? "Unknown Location";
        _currentCaption = "You are at $_locationName";
        notifyListeners();

        final ttsUrl = response['ttsUrl'];
        if (ttsUrl != null) {
          log('[TourController] TTS URL found: $ttsUrl');
          _isSpeaking = true;
          notifyListeners();
          
          // Fetch audio
          log('[TourController] Fetching audio from $ttsUrl...');
          final audioBytes = await _apiService.fetchAudio(ttsUrl);
          if (audioBytes != null) {
            log('[TourController] Audio received: ${audioBytes.length} bytes');
            debugPrint("Received audio: ${audioBytes.length} bytes");
            // TODO: Play audio
          } else {
            log('[TourController] Audio fetch failed (bytes null)');
          }
          
          // Simulate speaking end for now
          Future.delayed(const Duration(seconds: 3), () {
            _isSpeaking = false;
            notifyListeners();
          });
        } else {
          log('[TourController] No TTS URL in response');
        }
      } else {
        log('[TourController] User is OUTSIDE');
        _locationName = "Exploring...";
        _currentCaption = "Move closer to a landmark.";
        notifyListeners();
      }
    } else {
      log('[TourController] API Response was NULL');
    }
  }

  void startListening() {
    _isListening = true;
    _currentCaption = "Listening...";
    notifyListeners();
  }

  void stopListening() {
    _isListening = false;
    _currentCaption = "Processing question...";
    notifyListeners();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      _isSpeaking = true;
      _currentCaption = "I'm listening, but I can't answer just yet!";
      notifyListeners();

      Future.delayed(const Duration(seconds: 4), () {
        _isSpeaking = false;
        notifyListeners();
      });
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
