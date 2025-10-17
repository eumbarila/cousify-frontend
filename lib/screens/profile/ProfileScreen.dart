import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/widgets/bottom_nav.dart';
import 'package:cousify_frontend/widgets/profile_photo_picker.dart';
import 'package:cousify_frontend/services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  final bool showBottomNav;

  const ProfileScreen({Key? key, this.showBottomNav = true}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
    });
    try {
      // TODO: reemplazar por token real
      final token = '';
      final data = await UserService.getProfile(token);
      setState(() {
        _profile = data;
      });
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (picked == null) return;
    final File file = File(picked.path);
    try {
      final token = '';
      final resp = await UserService.uploadAvatar(token, file);
      // Actualizar perfil local con nueva URL
      setState(() {
        _profile ??= {};
        _profile!['avatar_url'] = resp['avatar_url'];
        if (resp.containsKey('avatar_thumbnail_url')) _profile!['avatar_thumbnail_url'] = resp['avatar_thumbnail_url'];
      });
    } catch (e) {
      print('Error uploading avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.backgroundFadeColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          'User Profile',
          style: TextStyle(color: AppColors.backgroundFadeColor),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
    body: _loading
      ? Center(child: CircularProgressIndicator())
      : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with avatar (fixed to avoid white-square behind icon)
                  Container(
                    color: AppColors.backgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        // Use a circular decorated container to avoid any rectangular artifacts
                        GestureDetector(
                          onTap: () async {
                            // Mostrar opciones y si se selecciona galería, lanzar picker
                            await showProfilePhotoOptions(context);
                            // After the modal closes, try picking image (we could detect which action was selected but for now use direct pick)
                            await _pickAndUploadAvatar();
                          },
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                              image: _profile != null && _profile!['avatar_url'] != null
                                  ? DecorationImage(
                                      image: NetworkImage(_profile!['avatar_url']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _profile != null && _profile!['avatar_url'] != null
                                ? null
                                : Center(
                                    child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // BASIC PROFILE section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BASIC PROFILE', style: TextStyle(color: AppColors.backgroundFadeColor.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.person, color: AppColors.backgroundFadeColor),
                                title: Text('Michael Jordan', style: TextStyle(color: AppColors.backgroundFadeColor)),
                              ),
                              Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.public, color: AppColors.backgroundFadeColor),
                                title: Text('http://www.michaeljordan.com', style: TextStyle(color: AppColors.backgroundFadeColor)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // PRIVATE INFORMATION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PRIVATE INFORMATION', style: TextStyle(color: AppColors.backgroundFadeColor.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.email, color: AppColors.backgroundFadeColor),
                                title: Text('michael@jordan.com', style: TextStyle(color: AppColors.backgroundFadeColor)),
                              ),
                              Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.phone_android, color: AppColors.backgroundFadeColor),
                                title: Text('+1 510 486 1234', style: TextStyle(color: AppColors.backgroundFadeColor)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Logout button area fixed at bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // For now just pop to root or close session placeholder
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  elevation: 4,
                ),
                child: Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
  bottomNavigationBar: widget.showBottomNav ? BottomNav(selectedIndex: 2) : null,
    );
  }
}
