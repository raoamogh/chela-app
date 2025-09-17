import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/auth_service.dart';
import '../widgets/custom_textfeild.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_signupPasswordController.text != _signupConfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }
    setState(() => _isLoading = true);
    final user = await _authService.signUpWithEmailPassword(
      _signupEmailController.text.trim(),
      _signupPasswordController.text.trim(),
    );
    _navigateToDashboard(user);
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final user = await _authService.signInWithEmailPassword(
      _loginEmailController.text.trim(),
      _loginPasswordController.text.trim(),
    );
    _navigateToDashboard(user);
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _authService.signInWithGoogle();
    _navigateToDashboard(user);
  }

  // --- THE CORRECTED LOGIC ---
  void _navigateToDashboard(dynamic user) {
    // First, always set loading to false, regardless of success or failure.
    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (user != null && mounted) {
      // If login was successful, navigate to the dashboard.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else if (mounted) {
      // If the user is null, it means login failed. Show an error message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Authentication Failed. Please check your credentials."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF121212)),
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    constraints: const BoxConstraints(maxHeight: 520),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildLoginForm(themeColor),
                        _buildSignUpForm(themeColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Welcome Back", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          CustomTextField(hintText: "Email", controller: _loginEmailController),
          const SizedBox(height: 20),
          CustomTextField(hintText: "Password", isPassword: true, controller: _loginPasswordController),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor, minimumSize: const Size(double.infinity, 50)),
                  child: const Text("Login", style: TextStyle(color: Color(0xFF121212), fontWeight: FontWeight.bold)),
                ),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildGoogleSignInButton(),
          const Spacer(),
          _buildSwitchFormText("Don't have an account?", "Sign up here", 1),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          CustomTextField(hintText: "Email", controller: _signupEmailController),
          const SizedBox(height: 20),
          CustomTextField(hintText: "Password", isPassword: true, controller: _signupPasswordController),
          const SizedBox(height: 20),
          CustomTextField(hintText: "Confirm Password", isPassword: true, controller: _signupConfirmPasswordController),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor, minimumSize: const Size(double.infinity, 50)),
                  child: const Text("Sign Up", style: TextStyle(color: Color(0xFF121212), fontWeight: FontWeight.bold)),
                ),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildGoogleSignInButton(),
          const Spacer(),
          _buildSwitchFormText("Already have an account?", "Login here", 0),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("OR", style: TextStyle(color: Colors.white54)),
        ),
        Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }
  
  Widget _buildGoogleSignInButton() {
    return OutlinedButton.icon(
          onPressed: _isLoading ? null : _handleGoogleSignIn,
          icon: const FaIcon(FontAwesomeIcons.google, size: 18),
          label: const Text("Sign in with Google"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: Colors.white24),
          ),
        );
  }

  Widget _buildSwitchFormText(String prompt, String action, int page) {
    return GestureDetector(
      onTap: () {
        if (!_isLoading) {
          _pageController.animateToPage(
            page,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
          children: [
            TextSpan(text: "$prompt "),
            TextSpan(
              text: action,
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}