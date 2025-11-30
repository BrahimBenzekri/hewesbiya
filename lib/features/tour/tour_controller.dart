import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hewesbiya/core/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';

class TourController extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _locationName = "Locating...";
  bool _isLoading = true;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentCaption = "Initializing tour...";
  String? _introText; // If not null, show intro screen

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
  String? get introText => _introText;
  bool get isLocationReady => _isLocationEnabled && _hasPermission;

  Future<bool> checkLocationRequirements() async {
    // ... (keep existing checkLocationRequirements logic)
    log('[TourController] checkLocationRequirements() called');
    LocationPermissionStatus status = await _locationService
        .checkPermissionStatus();
    // ...
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
    log('[TourController] loadTour() called');
    _isLoading = true;
    notifyListeners();

    // 1. Start Intro Sequence
    await _playIntroSequence();

    // 2. Check location
    if (!await checkLocationRequirements()) {
      log('[TourController] Location requirements failed');
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      log('[TourController] Getting current position...');
      final position = await _locationService.getCurrentPosition();
      await _handleLocationUpdate(position);

      _startLocationTracking();
    } catch (e) {
      log('[TourController] Error in loadTour: $e');
      _currentCaption = "Error connecting to tour service.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _playIntroSequence() async {
    final messages = ["ARE YOU READY?", "LOADING YOUR EXPERIENCE..."];

    for (final msg in messages) {
      _introText = msg;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
    }

    _introText = null; // End intro
    notifyListeners();
  }

  void _startLocationTracking() {
    log('[TourController] Starting location tracking stream...');
    _positionSubscription?.cancel();
    _positionSubscription = _locationService.getPositionStream().listen((
      position,
    ) async {
      log(
        '[TourController] Stream received position: ${position.latitude}, ${position.longitude}',
      );
      await _handleLocationUpdate(position);
    });
  }

  DateTime? _lastRequestTime;

  Future<void> _handleLocationUpdate(Position position) async {
    log(
      '[TourController] _handleLocationUpdate called with ${position.latitude}, ${position.longitude}',
    );

    // Debounce: Prevent requests within 5 seconds of the last one (longer for demo)
    if (_lastRequestTime != null &&
        DateTime.now().difference(_lastRequestTime!) <
            const Duration(seconds: 5)) {
      log('[TourController] Debounced: Skipping update (too soon)');
      return;
    }
    _lastRequestTime = DateTime.now();

    log('[TourController] Simulating API call...');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Response Logic
    log('[TourController] Simulating success response');
    _locationName = "The Main Entrance";
    _currentCaption = "You are at $_locationName";
    notifyListeners();

    // Play Local Audio
    if (!_isSpeaking) {
      log('[TourController] Playing local audio: assets/ai_demo.mp3');
      _isSpeaking = true;
      notifyListeners();

      try {
        await _audioPlayer.play(AssetSource('ai_demo.mp3'));

        _audioPlayer.onPlayerComplete.listen((event) {
          log('[TourController] Audio playback complete');
          _isSpeaking = false;
          notifyListeners();
        });
      } catch (e) {
        log('[TourController] Error playing audio: $e');
        _isSpeaking = false;
        notifyListeners();
      }
    } else {
      log('[TourController] Already speaking, skipping playback');
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
    _audioPlayer.dispose();
    super.dispose();
  }
}
