import 'package:flutter/material.dart';
import 'rive_favorite_button.dart';

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
    return RiveFavoriteButton(
      isFavorite: isFavorite,
      onPressed: onPressed,
    );
  }
}
