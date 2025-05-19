import 'package:flutter/material.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const FavoriteButton({
    Key? key,
    required this.isFavorite,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        size: const Size(30, 30),
        painter: _FavoriteButtonPainter(isFavorite: isFavorite),
      ),
    );
  }
}

class _FavoriteButtonPainter extends CustomPainter {
  final bool isFavorite;

  _FavoriteButtonPainter({required this.isFavorite});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = isFavorite ? const Color(0xFF2ECC71) : Colors.grey
      ..style = PaintingStyle.fill;

    // Draw heart shape
    final Path path = Path();
    
    // Starting point at the bottom of the heart
    path.moveTo(size.width / 2, size.height * 0.85);
    
    // Left curve
    path.cubicTo(
      size.width * 0.2, size.height * 0.6,
      size.width * 0.1, size.height * 0.35,
      size.width * 0.25, size.height * 0.25
    );
    
    // Left top curve
    path.cubicTo(
      size.width * 0.4, size.height * 0.15,
      size.width * 0.45, size.height * 0.25,
      size.width / 2, size.height * 0.35
    );
    
    // Right top curve
    path.cubicTo(
      size.width * 0.55, size.height * 0.25,
      size.width * 0.6, size.height * 0.15,
      size.width * 0.75, size.height * 0.25
    );
    
    // Right curve
    path.cubicTo(
      size.width * 0.9, size.height * 0.35,
      size.width * 0.8, size.height * 0.6,
      size.width / 2, size.height * 0.85
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}