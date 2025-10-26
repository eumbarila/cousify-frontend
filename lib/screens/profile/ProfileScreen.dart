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
  // controllers para edición
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // flags por campo para permitir edición
  bool _editingName = false;
  bool _editingWebsite = false;
  bool _editingEmail = false;
  bool _editingPhone = false;

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
        // inicializar controllers con los datos recibidos
        _nameController.text = _profile?['name'] ?? '';
        _websiteController.text = _profile?['website'] ?? '';
        _emailController.text = _profile?['email'] ?? '';
        _phoneController.text = _profile?['phone'] ?? '';
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
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Validaciones simples para los campos del perfil
  bool _isValidEmail(String email) {
    final pattern = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}");
    return pattern.hasMatch(email.trim());
  }

  bool _isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r"[ \-()]+"), "");
    if (cleaned.isEmpty) return true; // permitir vacío
      String s = cleaned;
      if (s.startsWith('+')) s = s.substring(1);
      if (s.length < 6 || s.length > 15) return false;
      return RegExp(r'^[0-9]+$').hasMatch(s);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  // guarda un campo concreto en el backend
  Future<void> _saveField(String key, String value, VoidCallback onRollback) async {
    try {
      final resp = await UserService.updateProfile({key: value});
      // actualizar localmente el perfil con la respuesta si existe
      setState(() {
        // esperamos que la API devuelva el objeto perfil actualizado
        _profile = resp;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Campo actualizado')),
        );
      }
    } catch (e) {
      // Si falla, revertir valor en controller y en UI
      onRollback();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
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
        actions: [
          // lápiz de editar perfil, menos visible
          IconButton(
            icon: Icon(
              Icons.edit,
              size: 20,
              color: AppColors.backgroundFadeColor.withOpacity(0.4),
            ),
            onPressed: () {
              // desbloquear todos los campos para edición rápida
              setState(() {
                _editingName = true;
                _editingWebsite = true;
                _editingEmail = true;
                _editingPhone = true;
              });
            },
            tooltip: 'Editar perfil',
          ),
        ],
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
                                      title: _editingName
                                          ? TextFormField(
                                              controller: _nameController,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Nombre',
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                              ),
                                              style: TextStyle(
                                                color:
                                                    AppColors.backgroundFadeColor,
                                              ),
                                              maxLines: 1,
                                              textAlignVertical: TextAlignVertical.center,
                                            )
                                          : Text(
                                              _profile?['name'] ??
                                                  'Nombre no disponible',
                                              style: TextStyle(
                                                color:
                                                    AppColors.backgroundFadeColor,
                                              ),
                                            ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          _editingName ? Icons.check : Icons.edit,
                                          color: _editingName
                                              ? Colors.green[600]
                                              : AppColors.backgroundFadeColor.withOpacity(0.4),
                                        ),
                                        tooltip: _editingName ? 'Guardar' : 'Editar',
                                        onPressed: () async {
                                          if (_editingName) {
                                            final old = _profile?['name'] ?? '';
                                            final newValue = _nameController.text;
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Confirmar cambio'),
                                                content: Text('¿Guardar cambio de nombre de "${old}" a "${newValue}"?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    child: Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    child: Text('Guardar'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirmed == true) {
                                              setState(() => _editingName = false);
                                              await _saveField('name', newValue, () {
                                                // rollback
                                                setState(() {
                                                  _nameController.text = old;
                                                });
                                              });
                                            } else {
                                              // si cancela, bloquear el campo (volver al estado previo al lápiz)
                                              setState(() => _editingName = false);
                                            }
                                          } else {
                                            setState(() => _editingName = true);
                                          }
                                        },
                                      ),
                                    ),
                                    Divider(height: 1),
                                    ListTile(
                                      leading: Icon(
                                        Icons.public,
                                        color: AppColors.backgroundFadeColor,
                                      ),
                                        title: _editingWebsite
                                            ? TextFormField(
                                                controller: _websiteController,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Website',
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                                ),
                                                style: TextStyle(
                                                  color:
                                                      AppColors.backgroundFadeColor,
                                                ),
                                                maxLines: 1,
                                                textAlignVertical: TextAlignVertical.center,
                                              )
                                            : Text(
                                                _profile?['website'] ??
                                                    'Sitio web no disponible',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.backgroundFadeColor,
                                                ),
                                              ),
                                        trailing: IconButton(
                                          icon: Icon(
                                            _editingWebsite ? Icons.check : Icons.edit,
                                            color: _editingWebsite
                                                ? Colors.green[600]
                                                : AppColors.backgroundFadeColor.withOpacity(0.4),
                                          ),
                                          tooltip: _editingWebsite ? 'Guardar' : 'Editar',
                                          onPressed: () async {
                                            if (_editingWebsite) {
                                              final old = _profile?['website'] ?? '';
                                              final newValue = _websiteController.text;
                                              final confirmed = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text('Confirmar cambio'),
                                                  content: Text('¿Guardar cambio del sitio web de "${old}" a "${newValue}"?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(true),
                                                      child: Text('Guardar'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirmed == true) {
                                                setState(() => _editingWebsite = false);
                                                await _saveField('website', newValue, () {
                                                  setState(() {
                                                    _websiteController.text = old;
                                                  });
                                                });
                                              } else {
                                                setState(() => _editingWebsite = false);
                                              }
                                            } else {
                                              setState(() => _editingWebsite = true);
                                            }
                                          },
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
                                      title: _editingEmail
                                          ? TextFormField(
                                              controller: _emailController,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Email',
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                              ),
                                              style: TextStyle(
                                                color:
                                                    AppColors.backgroundFadeColor,
                                              ),
                                              keyboardType: TextInputType.emailAddress,
                                              maxLines: 1,
                                              textAlignVertical: TextAlignVertical.center,
                                            )
                                          : Text(
                                              _profile?['email'] ??
                                                  'Email no disponible',
                                              style: TextStyle(
                                                color:
                                                    AppColors.backgroundFadeColor,
                                              ),
                                            ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          _editingEmail ? Icons.check : Icons.edit,
                                          color: _editingEmail
                                              ? Colors.green[600]
                                              : AppColors.backgroundFadeColor.withOpacity(0.4),
                                        ),
                                        tooltip: _editingEmail ? 'Guardar' : 'Editar',
                                        onPressed: () async {
                                          if (_editingEmail) {
                                            final old = _profile?['email'] ?? '';
                                            final newValue = _emailController.text;
                                            // Validar formato de email antes de confirmar
                                            if (!_isValidEmail(newValue)) {
                                              _showError('Email inválido');
                                              return;
                                            }
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Confirmar cambio'),
                                                content: Text('¿Guardar cambio de email de "${old}" a "${newValue}"?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    child: Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    child: Text('Guardar'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirmed == true) {
                                              setState(() => _editingEmail = false);
                                              await _saveField('email', newValue, () {
                                                setState(() {
                                                  _emailController.text = old;
                                                });
                                              });
                                            } else {
                                              setState(() => _editingEmail = false);
                                            }
                                          } else {
                                            setState(() => _editingEmail = true);
                                          }
                                        },
                                      ),
                                    ),
                                    Divider(height: 1),
                                    ListTile(
                                      leading: Icon(
                                        Icons.phone_android,
                                        color: AppColors.backgroundFadeColor,
                                      ),
                                      title: _editingPhone
                                          ? TextFormField(
                                              controller: _phoneController,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Teléfono',
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                              ),
                                              style: TextStyle(
                                                color:
                                                    AppColors.backgroundFadeColor,
                                              ),
                                              keyboardType: TextInputType.phone,
                                              maxLines: 1,
                                              textAlignVertical: TextAlignVertical.center,
                                            )
                                          : Text(
                                              _profile?['phone'] ??
                                                  'Teléfono no disponible',
                                              style: TextStyle(
                                                color:
                                                    AppColors.backgroundFadeColor,
                                              ),
                                            ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          _editingPhone ? Icons.check : Icons.edit,
                                          color: _editingPhone
                                              ? Colors.green[600]
                                              : AppColors.backgroundFadeColor.withOpacity(0.4),
                                        ),
                                        tooltip: _editingPhone ? 'Guardar' : 'Editar',
                                        onPressed: () async {
                                            if (_editingPhone) {
                                              final old = _profile?['phone'] ?? '';
                                              final newValue = _phoneController.text;
                                              // Validar teléfono (si no está vacío debe contener solo números y opcional +)
                                              if (newValue.trim().isNotEmpty && !_isValidPhone(newValue)) {
                                                _showError('Teléfono inválido. Sólo números y opcional +, longitud 6-15.');
                                                return;
                                              }
                                              final confirmed = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text('Confirmar cambio'),
                                                  content: Text('¿Guardar cambio de teléfono de "${old}" a "${newValue}"?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(true),
                                                      child: Text('Guardar'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirmed == true) {
                                                setState(() => _editingPhone = false);
                                                await _saveField('phone', newValue, () {
                                                  setState(() {
                                                    _phoneController.text = old;
                                                  });
                                                });
                                                } else {
                                                  setState(() => _editingPhone = false);
                                                }
                                            } else {
                                              setState(() => _editingPhone = true);
                                            }
                                        },
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
