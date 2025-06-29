import 'package:flutter/material.dart';

/// A stateless widget representing the header for recipe steps.
class RecipeStepsHeader extends StatelessWidget {
  const RecipeStepsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Text(
        'Шаги приготовления',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 23 / 16, // line-height from design
          color: Color(0xFF165932),
        ),
      ),
    );
  }
}