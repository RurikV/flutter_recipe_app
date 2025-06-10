import 'package:flutter/material.dart';

/// A stateless widget representing the container for the navigation bar.
class NavigationBarContainer extends StatelessWidget {
  final Widget child;

  const NavigationBarContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Height as per design
      decoration: const BoxDecoration(
        color: Colors.white, // White background as per design
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25), // Shadow as per design
            blurRadius: 8,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}