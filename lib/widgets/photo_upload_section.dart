import 'package:flutter/material.dart';

class PhotoUploadSection extends StatelessWidget {
  final TextEditingController controller;

  const PhotoUploadSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 17),
      child: Container(
        width: 396,
        height: 215,
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          border: Border.all(
            color: const Color(0xFF165932),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: Color(0xFF165932),
            ),
            const SizedBox(height: 8),
            const Text(
              'Добавить фото рецепта',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF165932),
              ),
            ),
            const SizedBox(height: 8),
            // Hidden field for image URL
            Opacity(
              opacity: 0,
              child: TextFormField(
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}