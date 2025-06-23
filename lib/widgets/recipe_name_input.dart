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
      padding: const EdgeInsets.only(top: 112),
      child: Center(
        child: Container(
          width: 396,
          height: 80, // Increased height to accommodate error message
          decoration: const BoxDecoration(
            color: Color(0xFFECECEC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: controller,
                    textAlign: TextAlign.center,
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
              ),
              Container(
                width: 396,
                height: 2,
                color: const Color(0xFF165932),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
