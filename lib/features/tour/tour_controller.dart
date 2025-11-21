import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hewesbiya/data/mock_data.dart';
import 'package:hewesbiya/core/location_service.dart';
import 'package:hewesbiya/core/api_service.dart';
import 'package:geolocator/geolocator.dart';


class TourController extends ChangeNotifier {
  final MockTourService _service = MockTourService();
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();
  
  List<TourStop> _stops = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentCaption = "Initializing tour...";
  
  // Location Status
  bool _isLocationEnabled = false;
  bool _hasPermission = false;
  StreamSubscription<Position>? _positionSubscription;

  // Getters
  TourStop? get currentStop => _stops.isNotEmpty ? _stops[_currentIndex] : null;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get currentCaption => _currentCaption;
  bool get hasNext => _currentIndex < _stops.length - 1;
  bool get isLocationReady => _isLocationEnabled && _hasPermission;

  Future<bool> checkLocationRequirements() async {
    LocationPermissionStatus status = await _locationService.checkPermissionStatus();
    
    _isLocationEnabled = status != LocationPermissionStatus.serviceDisabled;
    _hasPermission = status == LocationPermissionStatus.granted;
    
    if (status == LocationPermissionStatus.serviceDisabled) {
      _currentCaption = "Location services are disabled.";
      notifyListeners();
      return false;
    }

    if (status == LocationPermissionStatus.denied) {
      status = await _locationService.requestLocation();
      _hasPermission = status == LocationPermissionStatus.granted;
      
      if (status == LocationPermissionStatus.denied) {
        _currentCaption = "Location permission denied.";
        notifyListeners();
        return false;
      }
    }
    
    if (status == LocationPermissionStatus.deniedForever) {
      _currentCaption = "Location permission permanently denied.";
      notifyListeners();
      return false;
    }

    _hasPermission = true;
    notifyListeners();
    return true;
  }

  Future<void> loadTour() async {
    _isLoading = true;
    notifyListeners();
    
    // Check location first
    if (!await checkLocationRequirements()) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _stops = await _service.getStops();
      if (_stops.isNotEmpty) {
        _currentCaption = "Arrived at ${_stops[0].name}. ${_stops[0].description}";
        _isSpeaking = true; // Simulate auto-play on arrival
        // Send immediate location update to trigger backend
        try {
          final position = await _locationService.getCurrentPosition();
          final audioBytes = await _apiService.sendLocationUpdate(
            position.latitude, 
            position.longitude
          );
          if (audioBytes != null) {
            debugPrint("Received initial audio response: ${audioBytes.length} bytes");
          }
        } catch (e) {
          debugPrint("Error sending initial location: $e");
        }

        // Start tracking location
        _startLocationTracking();
        
        // Simulate speaking duration
        Future.delayed(const Duration(seconds: 3), () {
          _isSpeaking = false;
          notifyListeners();
        });
      }
    } catch (e) {
      _currentCaption = "Error loading tour data.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = _locationService.getPositionStream().listen((position) async {
      // Send location update to backend
      final audioBytes = await _apiService.sendLocationUpdate(
        position.latitude, 
        position.longitude
      );
      
      if (audioBytes != null) {
        // TODO: Handle audio playback when Audio Player is implemented
        debugPrint("Received audio response: ${audioBytes.length} bytes");
      }
    });
  }

  void nextStop() {
    if (hasNext) {
      _currentIndex++;
      _currentCaption = "Moving to ${_stops[_currentIndex].name}...";
      _isSpeaking = true;
      notifyListeners();

      // Simulate arrival and speaking
      Future.delayed(const Duration(seconds: 2), () {
        _currentCaption = _stops[_currentIndex].description;
        notifyListeners();
        
        Future.delayed(const Duration(seconds: 3), () {
          _isSpeaking = false;
          notifyListeners();
        });
      });
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
      _currentCaption = "That is a great question! The architecture here is influenced by Ottoman design.";
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
