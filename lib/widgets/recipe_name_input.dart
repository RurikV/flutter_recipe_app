import 'package:flutter/material.dart';

class RecipeNameInput extends StatelessWidget {
  final TextEditingController controller;

  const RecipeNameInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 112),
      child: Stack(
        children: [
          Container(
            width: 396,
            height: 80, // Increased height to accommodate error message
            decoration: const BoxDecoration(
              color: Color(0xFFECECEC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
          ),
          Positioned(
            left: 36.31,
            top: 120.17 - 112,
            child: const Text(
              'Название рецепта',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: Color(0xFF165932),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 80, // Adjusted to match the new container height
            child: Container(
              width: 396,
              height: 0,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF165932),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 36.31,
            top: 20,
            right: 16,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                isDense: true,
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Colors.black,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите название рецепта';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}