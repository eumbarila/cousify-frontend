import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/widgets/bottom_nav.dart';
import 'package:cousify_frontend/widgets/profile_photo_picker.dart';
import 'package:cousify_frontend/services/user_service.dart';
import 'package:cousify_frontend/screens/LoginScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      final data = await UserService.getProfile();
      setState(() {
        _profile = data;
      });
    } catch (e) {
      print('Error loading profile: $e');
      // Si falla cargar el perfil, mostrar snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
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
                                  // Mostrar opciones (avatar no funcional sin backend)
                                  await showProfilePhotoOptions(context);
                                },
                                child: Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                      _profile != null &&
                                          _profile!['avatar_url'] != null
                                      ? ClipOval(
                                          child: SvgPicture.network(
                                            _profile!['avatar_url'],
                                            fit: BoxFit.cover,
                                            width: 84,
                                            height: 84,
                                            placeholderBuilder:
                                                (
                                                  BuildContext context,
                                                ) => Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                          ),
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 30,
                                          ),
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
                              Text(
                                'BASIC PROFILE',
                                style: TextStyle(
                                  color: AppColors.backgroundFadeColor
                                      .withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Card(
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.person,
                                        color: AppColors.backgroundFadeColor,
                                      ),
                                      title: Text(
                                        _profile?['name'] ??
                                            'Nombre no disponible',
                                        style: TextStyle(
                                          color: AppColors.backgroundFadeColor,
                                        ),
                                      ),
                                    ),
                                    Divider(height: 1),
                                    ListTile(
                                      leading: Icon(
                                        Icons.public,
                                        color: AppColors.backgroundFadeColor,
                                      ),
                                      title: Text(
                                        _profile?['website'] ??
                                            'Sitio web no disponible',
                                        style: TextStyle(
                                          color: AppColors.backgroundFadeColor,
                                        ),
                                      ),
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
                              Text(
                                'PRIVATE INFORMATION',
                                style: TextStyle(
                                  color: AppColors.backgroundFadeColor
                                      .withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Card(
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        Icons.email,
                                        color: AppColors.backgroundFadeColor,
                                      ),
                                      title: Text(
                                        _profile?['email'] ??
                                            'Email no disponible',
                                        style: TextStyle(
                                          color: AppColors.backgroundFadeColor,
                                        ),
                                      ),
                                    ),
                                    Divider(height: 1),
                                    ListTile(
                                      leading: Icon(
                                        Icons.phone_android,
                                        color: AppColors.backgroundFadeColor,
                                      ),
                                      title: Text(
                                        _profile?['phone'] ??
                                            'Teléfono no disponible',
                                        style: TextStyle(
                                          color: AppColors.backgroundFadeColor,
                                        ),
                                      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 18.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Mostrar loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) =>
                                Center(child: CircularProgressIndicator()),
                          );

                          // Llamar al endpoint de logout
                          await UserService.logout();

                          // Cerrar loading dialog
                          if (mounted) Navigator.of(context).pop();

                          // Navegar a login reemplazando todo el stack
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          // Cerrar loading dialog si está abierto
                          if (mounted) Navigator.of(context).pop();

                          // Mostrar error pero igual hacer logout local
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Logout error, but session cleared locally',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );

                            // Navegar a login de todas formas
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: widget.showBottomNav
          ? BottomNav(selectedIndex: 2)
          : null,
    );
  }
}
