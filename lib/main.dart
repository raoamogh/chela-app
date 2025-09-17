import 'package:chela/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDZMTfsg7tvrhKCFPOr4-SM8o1tbVYW3cM',
      appId: '1:600402774838:android:13f23205cf64f2e50c8197',
      messagingSenderId: '600402774838',
      projectId: 'chela-prod',
      storageBucket: 'chela-prod.firebasestorage.app',
    ),
  );
  runApp(const ProviderScope(child: ChelaApp()));
}

class ChelaApp extends StatelessWidget {
  const ChelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Inter', // Make sure you've added this font
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF03E1FF), // Electric Blue
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}