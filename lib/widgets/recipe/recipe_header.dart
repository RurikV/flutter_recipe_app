import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../widgets/recipe/favorite_button.dart';
import '../../redux/app_state.dart';
import '../../screens/login_screen.dart';
import 'dart:async';

class RecipeHeader extends StatefulWidget {
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
  State<RecipeHeader> createState() => _RecipeHeaderState();
}

class _RecipeHeaderState extends State<RecipeHeader> {
  // Create a key to access the RiveFavoriteButton
  final favoriteButtonKey = GlobalKey<RiveFavoriteButtonState>();
  // Timer for animation
  Timer? _animationTimer;

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Required'),
          content: const Text('You need to be logged in to add recipes to favorites.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Login'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.recipeName,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                fontSize: 24,
                height: 22 / 24, // line-height from design
                color: Colors.black,
              ),
            ),
          ),
          StoreConnector<AppState, bool>(
            converter: (store) => store.state.isAuthenticated,
            builder: (context, isAuthenticated) {
              return FavoriteButton(
                isFavorite: widget.isFavorite,
                riveButtonKey: favoriteButtonKey,
                onPressed: isAuthenticated 
                  ? () {
                      print('RecipeHeader: onFavoriteToggle called');
                      // Call the original onFavoriteToggle callback
                      widget.onFavoriteToggle();

                      // Try to trigger the animation directly after a short delay
                      // This is in addition to the other approaches
                      _animationTimer?.cancel(); // Cancel any existing timer
                      _animationTimer = Timer(const Duration(milliseconds: 200), () {
                        print('RecipeHeader: Trying to trigger animation after delay');

                        // Try using the key first
                        if (favoriteButtonKey.currentState != null) {
                          print('RecipeHeader: Using key to trigger animation');
                          favoriteButtonKey.currentState!.triggerAnimation();
                        } else {
                          print('RecipeHeader: favoriteButtonKey.currentState is null');

                          // Since we can't directly access the RiveFavoriteButton state,
                          // we'll rely on the other approaches we've implemented:
                          // 1. The didUpdateWidget method in FavoriteButton
                          // 2. The onTap handler in RiveFavoriteButton
                          // 3. The direct animation triggering in RiveFavoriteButton.onTap

                          // As a last resort, we could try to find the button by key in the next frame
                          print('RecipeHeader: Will rely on other animation triggering approaches');
                        }
                      });
                    }
                  : () => _showLoginPrompt(context),
              );
            },
          ),
        ],
      ),
    );
  }
}
