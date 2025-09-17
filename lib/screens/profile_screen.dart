import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _courseController = TextEditingController();
  final _codechefController = TextEditingController();
  final _leetcodeController = TextEditingController();
  
  // This flag prevents the controllers from being reset on every rebuild
  bool _controllersInitialized = false;
  
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = [
      _nameController, _collegeController, _courseController,
      _codechefController, _leetcodeController,
    ];
    for (var controller in _controllers) {
      controller.addListener(_updateProgress);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  double _profileCompletion = 0.0;
  void _updateProgress() {
    int completedFields = 0;
    for (var controller in _controllers) {
      if (controller.text.trim().isNotEmpty) {
        completedFields++;
      }
    }
    if (mounted) {
      setState(() {
        _profileCompletion = completedFields / _controllers.length;
      });
    }
  }

  // This function populates the text fields when the data is first loaded
  void _updateControllers(UserProfile profile) {
    _nameController.text = profile.name;
    _collegeController.text = profile.college;
    _courseController.text = profile.course;
    _codechefController.text = profile.codechefUsername;
    _leetcodeController.text = profile.leetcodeUsername;
  }

  Future<void> _saveProfile() async {
    final profileData = {
      "name": _nameController.text.trim(),
      "college": _collegeController.text.trim(),
      "course": _courseController.text.trim(),
      "codechef_username": _codechefController.text.trim(),
      "leetcode_username": _leetcodeController.text.trim(),
    };
    
    final success = await ref.read(profileProvider.notifier).updateProfile(profileData);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Profile saved successfully!" : "Failed to save profile."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text("Save"),
          ),
        ],
      ),
      body: profileState.when(
        data: (profile) {
          // --- THE FIX ---
          // We only update the text fields if they haven't been initialized yet.
          if (!_controllersInitialized) {
            _updateControllers(profile);
            _controllersInitialized = true;
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildProfileHeader(profile),
                  const SizedBox(height: 30),
                  _buildExpansionSection(
                    title: "Personal Details",
                    icon: Icons.person_rounded,
                    isExpanded: true,
                    children: [
                      _buildProfileTextField(label: "Name", controller: _nameController),
                      const SizedBox(height: 16),
                      _buildProfileTextField(label: "College", controller: _collegeController),
                      const SizedBox(height: 16),
                      _buildProfileTextField(label: "Course", controller: _courseController),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExpansionSection(
                    title: "Coding Platforms",
                    icon: Icons.code_rounded,
                    children: [
                      _buildProfileTextField(label: "CodeChef Username", controller: _codechefController, assetIcon: 'assets/icons/codechef.svg'),
                      const SizedBox(height: 16),
                      _buildProfileTextField(label: "LeetCode Username", controller: _leetcodeController, assetIcon: 'assets/icons/leetcode.svg'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        error: (error, stack) => Center(child: Text("Error: ${error.toString()}")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              backgroundImage: currentUser?.photoURL != null ? NetworkImage(currentUser!.photoURL!) : null,
              child: currentUser?.photoURL == null 
                ? Icon(Icons.person_rounded, size: 60, color: Theme.of(context).colorScheme.primary) 
                : null,
            ),
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: () { /* TODO: Implement image picking */ },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                  child: Icon(Icons.edit_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text.isNotEmpty ? _nameController.text : (currentUser?.displayName ?? "Chela User"),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          currentUser?.email ?? "",
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 20),
        LinearPercentIndicator(
          percent: _profileCompletion,
          lineHeight: 8.0,
          barRadius: const Radius.circular(4),
          progressColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.white10,
          center: Text(
            "${(_profileCompletion * 100).toInt()}% Complete",
            style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildExpansionSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isExpanded = false,
  }) {
    return ExpansionTile(
      initiallyExpanded: isExpanded,
      leading: Icon(icon, color: Colors.white54),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      childrenPadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      collapsedIconColor: Colors.white,
      iconColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      collapsedBackgroundColor: const Color(0xFF1C1C1E),
      backgroundColor: const Color(0xFF1C1C1E),
      children: children,
    );
  }

  Widget _buildProfileTextField({
    required String label,
    required TextEditingController controller,
    String? assetIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: assetIcon != null 
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  assetIcon,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white54,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}