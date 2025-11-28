import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/services/auth_service.dart';
import 'package:cousify_frontend/screens/CoursesScreen.dart';
import 'package:cousify_frontend/screens/ProfileScreen.dart';
import 'package:cousify_frontend/screens/DownloadScreen.dart';
import 'package:cousify_frontend/screens/certificates_screen.dart';
import 'package:cousify_frontend/screens/ForgotPasswordEmailScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 120, height: 120),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to Coursify',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                    prefixIcon: Icon(Icons.email, color: AppColors.primaryColor),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                    prefixIcon: Icon(Icons.lock, color: AppColors.primaryColor),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                
                // Error message con diseño mejorado - ANTES del botón
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                ElevatedButton.icon(
                  onPressed: () async {
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();

                    setState(() => _errorMessage = null);

                    if (email.isEmpty || password.isEmpty) {
                      setState(() => _errorMessage = 'Email and password cannot be empty');
                      return;
                    }

                    try {
                      await AuthService.loginUser(email, password);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } catch (e) {
                      setState(() => _errorMessage = 'Incorrect email or password');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white, // Texto e icono blancos
                    minimumSize: Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Forgot Password link
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordEmailScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primaryColor, // Color del subrayado igual al texto
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CoursesScreen(),
    DownloadScreen(),
    ProfileScreen(showBottomNav: false),
    CertificatesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildIcon(Icons.view_list_rounded, 'Courses', 0),
            _buildIcon(Icons.save_alt_rounded, 'Download', 1),
            _buildIcon(Icons.person, 'Profile', 2),
            _buildIcon(Icons.workspace_premium, 'Certificates', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 35.0,
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.backgroundFadeColor,
          ),
          SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.primaryColor : AppColors.backgroundFadeColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
