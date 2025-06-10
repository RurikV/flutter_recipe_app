import 'package:flutter/material.dart';

/// A stateless widget representing the step duration.
class StepDuration extends StatelessWidget {
  final String duration;
  final bool isCompleted;
  final bool isCookingMode;

  const StepDuration({
    super.key,
    required this.duration,
    required this.isCompleted,
    required this.isCookingMode,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      duration,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w700,
        fontSize: 13,
        height: 20 / 13, // line-height from design
        color: isCookingMode && isCompleted 
            ? const Color(0xFF165932) // Green when completed in cooking mode
            : const Color(0xFF797676), // Default gray
      ),
    );
  }
}