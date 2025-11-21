import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hewesbiya/core/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCheckingLocation = false;
  bool _isModelLoaded = false;
  String _statusText = "SEARCHING FOR 5G NETWORK...";
  bool _hasError = false;

  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _startConnectionSequence();
  }

  Future<void> _startConnectionSequence() async {
    if (!mounted) return;
    setState(() {
      _isCheckingLocation = false;
      _isModelLoaded = false;
      _hasError = false;
      _statusText = "SEARCHING FOR 5G NETWORK...";
    });

    // 1. Simulate 5G Connection
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _statusText = "ACCESSING LOCATION...";
      _isCheckingLocation = true;
    });

    // 2. Check Location
    try {
      LocationPermissionStatus status = await _locationService.checkPermissionStatus();
      
      if (status == LocationPermissionStatus.denied) {
        status = await _locationService.requestLocation();
      }
      
      if (status == LocationPermissionStatus.serviceDisabled) {
        throw Exception("Location services disabled");
      }
      
      if (status == LocationPermissionStatus.denied) {
        throw Exception("Permission denied");
      }
      
      if (status == LocationPermissionStatus.deniedForever) {
        throw Exception("Permission permanently denied");
      }

      if (!mounted) return;
      setState(() {
        _isCheckingLocation = false;
        _statusText = "DOWNLOADING AI MODEL...";
      });

      // 3. Simulate Model Loading
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _isModelLoaded = true;
        _statusText = "SYSTEM READY";
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _statusText = "LOCATION ACCESS FAILED";
      });
      
      _showLocationErrorDialog(e.toString());
    }
  }

  void _showLocationErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Location Required"),
        content: Text(error.contains("disabled") 
            ? "Location services are disabled. Please enable them to continue."
            : "Location permission is required to find nearby tours."),
        actions: [
          if (error.contains("disabled"))
            TextButton(
              onPressed: _handleEnableLocation,
              child: const Text("Enable Location"),
            )
          else
            TextButton(
              onPressed: _handlePermissionRequest,
              child: const Text("Grant Permission"),
            ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _startConnectionSequence();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEnableLocation() async {
    await _locationService.openLocationSettings();
  }

  Future<void> _handlePermissionRequest() async {
    final status = await _locationService.requestLocation();
    if (status == LocationPermissionStatus.granted) {
      if (mounted) {
        Navigator.pop(context);
        _startConnectionSequence();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/logo_transparent.png',
                height: 150,
                fit: BoxFit.contain,
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 40),

              // Status Text
              if (!_isModelLoaded && !_hasError)
                Text(
                  _statusText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    letterSpacing: 2,
                    color: _isCheckingLocation 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                )
                .animate(key: ValueKey(_statusText))
                .fadeIn(duration: 500.ms)
                .then(delay: 1.seconds)
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2.seconds),

              if (_hasError)
                Text(
                  _statusText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().shake(),

              if (_isModelLoaded)
                Column(
                  children: [
                    Text(
                      "SYSTEM READY",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/tour');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "START TOUR",
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).moveY(begin: 20, end: 0),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
