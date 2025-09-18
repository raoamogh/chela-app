import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:image_picker/image_picker.dart'; // <<< Official Image Picker
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Your existing imports
import '../providers/profile_provider.dart';
import '../models/user_profile_model.dart';
import '../api/api_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  File? _pickedImage;
  bool _isUploadingImage = false;

  late final TextEditingController _nameController;
  late final TextEditingController _collegeController;
  late final TextEditingController _courseController;
  late final TextEditingController _codechefController;
  late final TextEditingController _leetcodeController;

  bool _controllersInitialized = false;
  late final List<TextEditingController> _controllers;

  // --- IMPORTANT: PASTE YOUR CLOUDINARY CREDENTIALS HERE ---
  static const String _cloudinaryCloudName = 'dqhzvd3u9';
  static const String _cloudinaryApiKey = '916246345417713';
  static const String _cloudinaryApiSecret = '_FS9a0I1OIFoR7aGxTCSon89xlY'; 
  static const String _uploadPreset = 'chela_profile_pics'; 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _collegeController = TextEditingController();
    _courseController = TextEditingController();
    _codechefController = TextEditingController();
    _leetcodeController = TextEditingController();

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
    if (!mounted) return;
    int completedFields = 0;
    for (var controller in _controllers) {
      if (controller.text.trim().isNotEmpty) {
        completedFields++;
      }
    }
    setState(() {
      _profileCompletion = completedFields / _controllers.length;
    });
  }

  void _updateControllers(UserProfile profile) {
    _nameController.text = profile.name;
    _collegeController.text = profile.college;
    _courseController.text = profile.course;
    _codechefController.text = profile.codechefUsername;
    _leetcodeController.text = profile.leetcodeUsername;
    _updateProgress(); 
  }

  // --- UPDATED: Image Picking Logic using official image_picker ---
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImageFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress the image to save space
      maxWidth: 300,   // Resize the image for profile pictures
    );

    if (pickedImageFile != null) {
      final File imageFile = File(pickedImageFile.path);
      setState(() {
        _pickedImage = imageFile;
        _isUploadingImage = true; // Start loading indicator
      });

      try {
        final String? imageUrl = await _uploadImageToCloudinary(imageFile);
        if (imageUrl != null) {
          await currentUser?.updatePhotoURL(imageUrl); 
          await ref.read(profileProvider.notifier).updateProfile({"photoURL": imageUrl}); 

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile picture updated!")),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to upload image to Cloudinary.")),
            );
          }
        }
      } catch (e) {
        print("Error uploading image to Cloudinary: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading image: ${e.toString()}")),
          );
        }
      } finally {
        setState(() {
          _isUploadingImage = false; // Stop loading indicator
        });
      }
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    //

    try {
      final cloudinary = CloudinaryPublic(_cloudinaryCloudName, _uploadPreset, cache: false);
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print("Cloudinary error: ${e.message} - ${e.request}");
      return null;
    } catch (e) {
      print("Unknown upload error: $e");
      return null;
    }
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
              // Show the picked image preview or current user photoURL
              backgroundImage: _pickedImage != null
                  ? FileImage(_pickedImage!) as ImageProvider
                  : (currentUser?.photoURL != null ? NetworkImage(currentUser!.photoURL!) : null),
              child: _pickedImage == null && currentUser?.photoURL == null 
                ? Icon(Icons.person_rounded, size: 60, color: Theme.of(context).colorScheme.primary) 
                : null,
            ),
            if (_isUploadingImage)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: _pickAndUploadImage,
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