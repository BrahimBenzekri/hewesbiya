import 'package:flutter/material.dart';
import 'package:hewesbiya/core/theme.dart';
import 'package:hewesbiya/features/home/home_screen.dart';
import 'package:hewesbiya/features/tour/tour_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '7ewesbiya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/tour': (context) => const TourScreen(),
      },
    );
  }
}
