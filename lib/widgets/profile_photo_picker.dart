import 'package:flutter/material.dart';

/// Muestra un modal con opciones para elegir foto de la galería o cancelar.
Future<void> showProfilePhotoOptions(BuildContext context) async {
  // Usamos showModalBottomSheet con fondo semitransparente más oscuro
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54, // oscurecer más el fondo
    isScrollControlled: false,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo Library button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    // Aquí podrías lanzar ImagePicker o lógica para seleccionar una imagen
                  },
                  child: Center(child: Text('Photo Library', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel button separado
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Center(child: Text('Cancel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// helper removed; options are built inline
