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

          // Did You Know Card
          _buildDidYouKnowCard().animate().fadeIn(delay: 400.ms).scale(),

          const SizedBox(height: 32),

          // Start Tour Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/tour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    "START TOUR",
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0),

          const SizedBox(height: 32),

          // Quick Actions
          Text(
            "Quick Actions",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 800.ms),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildActionButton(
                context,
                Icons.map_outlined,
                "Map View",
                Colors.blue,
              ),
              _buildActionButton(
                context,
                Icons.bookmark_border_rounded,
                "Saved",
                Colors.orange,
              ),
              _buildActionButton(
                context,
                Icons.history_rounded,
                "History",
                Colors.purple,
              ),
              _buildActionButton(
                context,
                Icons.settings_outlined,
                "Settings",
                Colors.grey,
              ),
            ],
          ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),
        ],
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

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$label feature coming soon!")),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
