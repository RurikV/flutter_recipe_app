import 'package:flutter/material.dart';

/// A stateless widget representing the step number.
class StepNumber extends StatelessWidget {
  final int index;
  final bool isCompleted;
  final bool isCookingMode;

  const StepNumber({
    super.key,
    required this.index,
    required this.isCompleted,
    required this.isCookingMode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Text(
        '${index + 1}',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w900,
          fontSize: 40,
          height: 27 / 40, // line-height from design
          color: isCookingMode && isCompleted 
              ? const Color(0xFF2ECC71) // Green when completed in cooking mode
              : const Color(0xFFC2C2C2), // Default gray
        ),
      ),
    );
  }
}