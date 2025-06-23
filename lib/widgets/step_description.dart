import 'package:flutter/material.dart';

/// A stateless widget representing the step description.
class StepDescription extends StatelessWidget {
  final String description;
  final bool isCompleted;
  final bool isCookingMode;

  const StepDescription({
    super.key,
    required this.description,
    required this.isCompleted,
    required this.isCookingMode,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          description,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 18 / 12, // line-height from design
            color: isCookingMode && isCompleted 
                ? const Color(0xFF2D490C) // Dark green when completed in cooking mode
                : const Color(0xFF797676), // Default gray
          ),
        ),
      ),
    );
  }
}