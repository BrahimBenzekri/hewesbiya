import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hewesbiya/core/location_service.dart';
import 'dart:ui';

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
      LocationPermissionStatus status = await _locationService
          .checkPermissionStatus();

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
        content: Text(
          error.contains("disabled")
              ? "Location services are disabled. Please enable them to continue."
              : "Location permission is required to find nearby tours.",
        ),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning,";
    if (hour < 18) return "Good Afternoon,";
    return "Good Evening,";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: _isModelLoaded
              ? _buildDashboard(context)
              : _buildLoadingState(context),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo_transparent.png',
            height: 120,
            fit: BoxFit.contain,
          ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),

          const SizedBox(height: 40),

          if (!_hasError)
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
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/logo_transparent.png', height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ),
            ],
          ).animate().fadeIn().slideY(begin: -0.5),

          const SizedBox(height: 32),

          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Explorer",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

          const SizedBox(height: 32),

          // Nearby Landmark Section
          Text(
            "NEARBY TOUR DETECTED",
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 16),

          // Landmark Card
          _buildLandmarkCard(context).animate().fadeIn(delay: 600.ms).scale(),

          const SizedBox(height: 10),

          // Did You Know Card (Secondary)
          _buildDidYouKnowCard()
              .animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildLandmarkCard(BuildContext context) {
    return Container(
      height: 340,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image
            Image.asset('assets/great_mosque_hero.jpeg', fit: BoxFit.cover),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Content Overlay
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "The Great Mosque\nof Algiers",
                    style: GoogleFonts.dmSerifDisplay(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "A journey through faith and architecture.",
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/tour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "START EXPERIENCE",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDidYouKnowCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "DID YOU KNOW?",
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "The Casbah of Algiers is a UNESCO World Heritage site, preserving the ruins of the old citadel, mosques and Ottoman-style palaces.",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
