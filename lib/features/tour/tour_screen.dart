import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hewesbiya/features/tour/tour_controller.dart';
import 'package:provider/provider.dart';

class TourScreen extends StatelessWidget {
  const TourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TourController()..loadTour(),
      child: const _TourView(),
    );
  }
}

class _TourView extends StatelessWidget {
  const _TourView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TourController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true, // Allow gradient to show through AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          controller.locationName.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        centerTitle: true,
        actions: [],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [
                    theme.colorScheme.secondary.withValues(alpha: 0.2),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Stack(
              children: [
                if (controller.introText != null)
            Center(
              child:
                  Text(
                        controller.introText!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary, // Blue text
                          letterSpacing: 2.0,
                        ),
                      )
                      .animate(
                        key: ValueKey(controller.introText),
                      ) // Re-run animation on text change
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 400.ms,
                      )
                      .then(delay: 1200.ms)
                      .fadeOut(duration: 400.ms),
            )
          else if (!controller.isLocationReady)
             Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 60,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Location Required",
                      style: theme.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.currentCaption,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => controller.loadTour(),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Try Again / Grant Permission"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary, // Blue button
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // AI Orb Visual
                Center(
                  child: AvatarGlow(
                    animate: controller.isSpeaking || controller.isListening,
                    glowColor: controller.isListening
                        ? theme.primaryColor // Orange when listening
                        : theme.colorScheme.secondary, // Blue when speaking/idle
                    duration: const Duration(milliseconds: 2000),
                    repeat: true,
                    child: Material(
                      elevation: 8.0,
                      shape: const CircleBorder(),
                      color: Colors.transparent,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.scaffoldBackgroundColor,
                          border: Border.all(
                            color: controller.isListening
                                ? theme.primaryColor
                                : theme.colorScheme.secondary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (controller.isListening
                                          ? theme.primaryColor
                                          : theme.colorScheme.secondary)
                                      .withValues(alpha: 0.6),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          controller.isListening ? Icons.mic : Icons.graphic_eq,
                          size: 50,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 600.ms),

                const Spacer(),

                // Captions Area
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  height: 100,
                  alignment: Alignment.center,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      controller.currentCaption,
                      key: ValueKey(controller.currentCaption),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.9,
                        ),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Hold to Speak Button
                GestureDetector(
                      onLongPressStart: (_) => controller.startListening(),
                      onLongPressEnd: (_) => controller.stopListening(),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 50),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.mic_none,
                          color: theme.colorScheme.onSurface,
                          size: 32,
                        ),
                      ),
                    )
                    .animate(target: controller.isListening ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 200.ms,
                    ),
              ],
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
