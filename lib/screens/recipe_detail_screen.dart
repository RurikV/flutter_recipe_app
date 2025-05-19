import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/comment.dart';
import '../services/recipe_manager.dart';
import '../widgets/favorite_button.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeManager _recipeManager = RecipeManager();
  final TextEditingController _commentController = TextEditingController();
  late Recipe _recipe;
  bool _isAddingComment = false;
  bool _isCookingMode = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    final success = await _recipeManager.toggleFavorite(_recipe.uuid);
    if (success && mounted) {
      setState(() {
        _recipe.isFavorite = !_recipe.isFavorite;
      });
    }
  }

  void _addComment() async {
    if (_commentController.text.isEmpty) return;

    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'User', // In a real app, this would be the current user's name
      text: _commentController.text,
      date: DateTime.now().toString().substring(0, 10), // Format: YYYY-MM-DD
    );

    final success = await _recipeManager.addComment(_recipe.uuid, comment);
    if (success && mounted) {
      setState(() {
        // Update the local recipe object with the new comment
        final updatedComments = List<Comment>.from(_recipe.comments)..add(comment);
        _recipe = Recipe(
          uuid: _recipe.uuid,
          name: _recipe.name,
          images: _recipe.images,
          description: _recipe.description,
          instructions: _recipe.instructions,
          difficulty: _recipe.difficulty,
          duration: _recipe.duration,
          rating: _recipe.rating,
          tags: _recipe.tags,
          ingredients: _recipe.ingredients,
          steps: _recipe.steps,
          isFavorite: _recipe.isFavorite,
          comments: updatedComments,
        );
        _commentController.clear();
        _isAddingComment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Рецепт'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality would go here
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              width: orientation == Orientation.landscape
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // Recipe name and favorite button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _recipe.name,
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
                    isFavorite: _recipe.isFavorite,
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
            ),

            // Duration with clock icon
            Padding(
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
                    widget.recipe.duration,
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
            ),

            // Recipe image
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  widget.recipe.images,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
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
                ),
              ),
            ),

            // Ingredients section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Text(
                'Ингредиенты',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 23 / 16, // line-height from design
                  color: Color(0xFF165932),
                ),
              ),
            ),

            // Ingredients list
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF797676), width: 3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(1),
                    },
                    children: widget.recipe.ingredients.map((ingredient) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              ingredient.name,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                height: 27 / 14, // line-height from design
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '${ingredient.quantity} ${ingredient.unit}',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                height: 27 / 13, // line-height from design
                                color: Color(0xFF797676),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Steps section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Text(
                'Шаги приготовления',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 23 / 16, // line-height from design
                  color: Color(0xFF165932),
                ),
              ),
            ),

            // Steps list
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: List.generate(widget.recipe.steps.length, (index) {
                  final step = widget.recipe.steps[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isCookingMode && step.isCompleted 
                            ? const Color(0xFFE8F5E9) // Light green when completed in cooking mode
                            : const Color(0xFFECECEC), // Default gray
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step number
                            SizedBox(
                              width: 30,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 40,
                                  height: 27 / 40, // line-height from design
                                  color: _isCookingMode && step.isCompleted 
                                      ? const Color(0xFF2ECC71) // Green when completed in cooking mode
                                      : const Color(0xFFC2C2C2), // Default gray
                                ),
                              ),
                            ),

                            // Step description
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  step.description,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 18 / 12, // line-height from design
                                    color: _isCookingMode && step.isCompleted 
                                        ? const Color(0xFF2D490C) // Dark green when completed in cooking mode
                                        : const Color(0xFF797676), // Default gray
                                  ),
                                ),
                              ),
                            ),

                            // Step duration and checkbox
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Checkbox(
                                  value: step.isCompleted,
                                  onChanged: _isCookingMode ? (value) async {
                                    final newValue = value ?? false;
                                    final success = await _recipeManager.updateStepStatus(
                                      _recipe.uuid,
                                      index,
                                      newValue,
                                    );
                                    if (success && mounted) {
                                      setState(() {
                                        step.isCompleted = newValue;
                                      });
                                    }
                                  } : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  side: BorderSide(
                                    color: _isCookingMode ? const Color(0xFF165932) : const Color(0xFF797676),
                                    width: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  step.duration,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    height: 20 / 13, // line-height from design
                                    color: _isCookingMode && step.isCompleted 
                                        ? const Color(0xFF165932) // Green when completed in cooking mode
                                        : const Color(0xFF797676), // Default gray
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Start cooking button
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isCookingMode = !_isCookingMode;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCookingMode ? Colors.white : const Color(0xFF165932),
                    foregroundColor: _isCookingMode ? const Color(0xFF165932) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: _isCookingMode ? const BorderSide(color: Color(0xFF165932), width: 3) : BorderSide.none,
                    ),
                    minimumSize: const Size(232, 48),
                  ),
                  child: Text(
                    _isCookingMode ? 'Закончить готовить' : 'Начать готовить',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 23 / 16, // line-height from design
                    ),
                  ),
                ),
              ),
            ),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Color(0xFF797676),
                thickness: 0.5,
              ),
            ),

            // Comments section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comments header
                  const Text(
                    'Комментарии',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 23 / 16, // line-height from design
                      color: Color(0xFF165932),
                    ),
                  ),

                  // Comments list
                  if (_recipe.comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: Text(
                        'Нет комментариев',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF797676),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recipe.comments.length,
                      itemBuilder: (context, index) {
                        final comment = _recipe.comments[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    comment.authorName,
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF2ECC71),
                                    ),
                                  ),
                                  Text(
                                    comment.date,
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Color(0xFFC2C2C2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment.text,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              if (index < _recipe.comments.length - 1)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Divider(
                                    color: Color(0xFFECECEC),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                  // Add comment button or form
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: _isAddingComment
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF165932),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: TextField(
                                    controller: _commentController,
                                    decoration: const InputDecoration(
                                      hintText: 'Оставить комментарий',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Color(0xFFC2C2C2),
                                      ),
                                      border: InputBorder.none,
                                      suffixIcon: Icon(
                                        Icons.image,
                                        color: Color(0xFF797676),
                                      ),
                                    ),
                                    maxLines: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isAddingComment = false;
                                        _commentController.clear();
                                      });
                                    },
                                    child: const Text(
                                      'Отмена',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Color(0xFF797676),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _addComment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF165932),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      minimumSize: const Size(120, 40),
                                    ),
                                    child: const Text(
                                      'Отправить',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Center(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isAddingComment = true;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF165932),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                minimumSize: const Size(232, 48),
                              ),
                              child: const Text(
                                'Добавить комментарий',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color(0xFF165932),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
