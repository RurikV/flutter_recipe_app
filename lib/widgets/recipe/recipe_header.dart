import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../widgets/recipe/favorite_button.dart';
import '../../redux/app_state.dart';
import '../../screens/login_screen.dart';

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
          StoreConnector<AppState, bool>(
            converter: (store) => store.state.isAuthenticated,
            builder: (context, isAuthenticated) {
              return FavoriteButton(
                isFavorite: isFavorite,
                onPressed: isAuthenticated 
                  ? onFavoriteToggle 
                  : () => _showLoginPrompt(context),
              );
            },
          ),
        ],
      ),
    );
  }
}
