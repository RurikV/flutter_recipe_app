import 'package:flutter/material.dart';
import 'rive_favorite_button.dart';

// Explicitly import the RiveFavoriteButtonState class to ensure it's accessible
export 'rive_favorite_button.dart' show RiveFavoriteButtonState;

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onPressed;
  final Key? riveButtonKey;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.riveButtonKey,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  // Key to access the RiveFavoriteButton
  final GlobalKey<RiveFavoriteButtonState> _riveButtonKey = GlobalKey<RiveFavoriteButtonState>();

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the favorite state changed, try to trigger the animation
    if (oldWidget.isFavorite != widget.isFavorite) {
      print('FavoriteButton: Favorite state changed from ${oldWidget.isFavorite} to ${widget.isFavorite}');

      // Use a small delay to ensure the RiveFavoriteButton has been updated
      Future.delayed(Duration.zero, () {
        // Try to trigger the animation through the key
        _riveButtonKey.currentState?.triggerAnimation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RiveFavoriteButton(
      key: widget.riveButtonKey ?? _riveButtonKey,
      isFavorite: widget.isFavorite,
      onPressed: widget.onPressed,
    );
  }
}
