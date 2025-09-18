// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chela/firebase_options.dart';
import 'package:chela/screens/auth_screen.dart';
import 'package:chela/screens/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chela/theme/theme.dart'; // Ensure your theme is imported
import 'package:chela/api/notification_service.dart'; // IMPORTANT: Ensure this import is present
import 'package:chela/screens/landing_screen.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized() is crucial for native code interaction
  // and must be called before any Flutter-specific plugin calls (like Firebase.initializeApp()).
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase services
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDZMTfsg7tvrhKCFPOr4-SM8o1tbVYW3cM',
      appId: '1:600402774838:android:13f23205cf64f2e50c8197',
      messagingSenderId: '600402774838',
      projectId: 'chela-prod',
      storageBucket: 'chela-prod.firebasestorage.app',
    ),
  );

  // Run the Flutter app, wrapped in ProviderScope for Riverpod
  runApp(const ProviderScope(child: ChelaApp()));
}

// ChelaApp is now a ConsumerWidget to allow it to interact with Riverpod providers.
class ChelaApp extends ConsumerWidget {
  const ChelaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef ref
    // --- IMPORTANT: Initialize NotificationService via its Riverpod provider ---
    // By reading the `notificationServiceProvider` here, we ensure that:
    // 1. The `NotificationService` instance is created.
    // 2. Its `init()` method is called (as defined in `notification_service.dart`).
    // 3. The service remains active due to `keepAlive: true`.
    ref.read(notificationServiceProvider);

    return MaterialApp(
      title: 'Chela',
      debugShowCheckedModeBanner: false, // Set to true if you want the debug banner for development
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Dark background color
        fontFamily: 'Inter', // Ensure you've added the 'Inter' font to your pubspec.yaml
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF03E1FF), // Your Electric Blue primary color
          // You might want to define other colors like secondary, surface, background, etc.
          // to fully support your app's theme.
        ),
        // Add other theme properties like appBarTheme, textTheme, buttonTheme, etc. as needed.
      ),
      // The home screen, which will likely handle routing based on user authentication state.
      home: const LandingScreen(),
      // Consider using a named routes or a routing package (like go_router) for larger apps.
      // routes: {
      //   '/auth': (context) => const AuthScreen(),
      //   '/dashboard': (context) => const DashboardScreen(),
      // },
    );
  }
}