import 'package:flutter/material.dart';

class DurationDisplay extends StatelessWidget {
  final String duration;

  const DurationDisplay({
    super.key,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Icon(
            Icons.access_time,
            size: 16,
            color: Color(0xFF2ECC71),
          ),
          const SizedBox(width: 8),
          Text(
            duration,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 19 / 16, // line-height from design
              color: Color(0xFF2ECC71),
            ),
          ),
        ],
      ),
    );
  }
}