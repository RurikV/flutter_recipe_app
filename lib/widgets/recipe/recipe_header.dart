import 'package:flutter/material.dart';
import '../../widgets/recipe/favorite_button.dart';

class RecipeHeader extends StatelessWidget {
  final String recipeName;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const RecipeHeader({
    super.key,
    required this.recipeName,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              recipeName,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                fontSize: 24,
                height: 22 / 24, // line-height from design
                color: Colors.black,
              ),
            ),
          ),
          FavoriteButton(
            isFavorite: isFavorite,
            onPressed: onFavoriteToggle,
          ),
        ],
      ),
    );
  }
}