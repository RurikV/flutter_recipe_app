import 'package:flutter/material.dart';

class CookingModeButton extends StatelessWidget {
  final bool isCookingMode;
  final VoidCallback onPressed;

  const CookingModeButton({
    super.key,
    required this.isCookingMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isCookingMode ? Colors.white : const Color(0xFF165932),
            foregroundColor: isCookingMode ? const Color(0xFF165932) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: isCookingMode ? const BorderSide(color: Color(0xFF165932), width: 3) : BorderSide.none,
            ),
            minimumSize: const Size(232, 48),
          ),
          child: Text(
            isCookingMode ? 'Закончить готовить' : 'Начать готовить',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 23 / 16, // line-height from design
            ),
          ),
        ),
      ),
    );
  }
}