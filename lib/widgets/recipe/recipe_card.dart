import 'package:flutter/material.dart';
import '../../../models/recipe.dart';
import '../../screens/recipe_detail_screen.dart';
import 'bookmark_indicator.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Stack(
        children: [
          // Base card
          Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            height: 136, // Fixed height as per design
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0), // 5px border radius as per design
              ),
              elevation: 4,
              shadowColor: const Color.fromRGBO(149, 146, 146, 0.1), // Shadow color as per design
              child: Row(
                children: [
                  // Recipe image - Left side of the card
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                    ),
                    child: SizedBox(
                      width: 150, // Width of the image (about 37.63% of card width)
                      height: 136, // Full height of the card
                      child: recipe.images.isNotEmpty
                        ? Image.network(
                            recipe.images.first.path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                    ),
                  ),

                  // Recipe details - Right side of the card
                  Expanded(
                    child: ColoredBox(
                      // Use ColoredBox instead of Container
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recipe name
                            Padding(
                              padding: const EdgeInsets.only(top: 14.0),
                              // Position as per design
                              child: Text(
                                recipe.name,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  // Medium weight as per design
                                  fontSize: 22,
                                  // 22px as per design
                                  height: 1.0,
                                  // Line height as per design
                                  color: Colors.black,
                                ),
                                maxLines: 2, // Two lines as per design
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const Spacer(), // Push the duration to the bottom
                            // Duration with clock icon
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              // Position as per design
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time, // Clock icon
                                    size: 16.0,
                                    color: Color(0xFF2ECC71), // Green color as per design
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    recipe.duration,
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      // Regular weight as per design
                                      fontSize: 16,
                                      // 16px as per design
                                      height: 19 / 16,
                                      // Line height as per design
                                      color: Color(0xFF2ECC71), // Green color as per design
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bookmark indicator for favorite recipes
          if (recipe.isFavorite)
            Positioned(
              top: 23, // Position as per design
              right: 0,
              child: const BookmarkIndicator(),
            ),
        ],
      ),
    );
  }
}
