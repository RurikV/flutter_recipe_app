import 'package:flutter/material.dart';
import 'nav_item_icon.dart';
import 'nav_item_label.dart';

/// A stateless widget representing a navigation item in the bottom navigation bar.
class NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final Function(int) onTap;

  const NavItem({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? const Color(0xFF2ECC71) : const Color(0xFFC2C2C2);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NavItemIcon(
              icon: icon,
              color: color,
            ),
            const SizedBox(height: 4),
            NavItemLabel(
              label: label,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}