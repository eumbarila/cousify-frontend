import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const BottomNav({Key? key, this.selectedIndex = 0, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildIcon(context, Icons.view_list_rounded, 'Courses', 0),
            _buildIcon(context, Icons.save_alt_rounded, 'Downloads', 1),
            _buildIcon(context, Icons.person, 'Profile', 2),
            _buildIcon(context, Icons.more_horiz, 'More', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    Color color = isSelected ? AppColors.primaryColor : AppColors.backgroundFadeColor;
    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!(index);
        // If no onTap provided, try to navigate within parent HomePage if present
        if (onTap == null) {
          // attempt to find a Scaffold ancestor and change body isn't possible here;
          // keep this widget passive when no onTap provided.
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
