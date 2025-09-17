import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'auth_screen.dart';
import '../widgets/animated_background.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // The new, reliable animated background
          const AnimatedBackground(),

          // The main content on top
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Logo
                  Image.asset(
                    'assets/images/chela_logo.png',
                    width: 200,
                    height: 200,
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                      .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  // Main tagline with Google Fonts
                  Text(
                    "Your AI Academic Strategist",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 800.ms)
                      .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOut),

                  const SizedBox(height: 16),
                  
                  // Supporting text with Google Fonts
                  Text(
                    "Chela organizes your schedule, tracks your progress, and helps you achieve your goals without the burnout.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white60,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 800.ms)
                      .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOut),
                  
                  const Spacer(),

                  // Call to Action Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const AuthScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          transitionDuration: 600.ms,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Get Started",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF121212),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 800.ms)
                      .slideY(begin: 0.5, end: 0, duration: 800.ms, curve: Curves.easeOut),
                      
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}