import 'package:flutter/material.dart';

/// A stateless widget representing the label in a navigation item.
class NavItemLabel extends StatelessWidget {
  final String label;
  final Color color;

  const NavItemLabel({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: color,
      ),
    );
  }
}