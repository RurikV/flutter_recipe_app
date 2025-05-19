import 'package:flutter/material.dart';

class BookmarkIndicator extends StatelessWidget {
  final int count;

  const BookmarkIndicator({
    Key? key,
    this.count = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 23,
      child: CustomPaint(
        painter: _BookmarkPainter(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF2ECC71) // Green color as per design
      ..style = PaintingStyle.fill;

    // Create a path for the bookmark shape
    final Path path = Path();

    // Draw the main rectangle
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw the triangle at the bottom
    path.moveTo(size.width * 0.38, size.height);
    path.lineTo(size.width * 0.5, size.height * 1.5);
    path.lineTo(size.width * 0.62, size.height);
    path.close();

    // Draw the shape
    canvas.drawPath(path, paint);

    // Add shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withAlpha(64) // 0.25 * 255 = 63.75, rounded to 64
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
