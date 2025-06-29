import 'package:flutter/material.dart';

/// A stateless widget representing the icon in a navigation item.
class NavItemIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const NavItemIcon({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: 24,
    );
  }
}