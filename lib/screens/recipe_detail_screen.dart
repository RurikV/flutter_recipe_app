import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/recipe_step.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe name
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Text(
                widget.recipe.name,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  height: 22 / 24, // line-height from design
                  color: Colors.black,
                ),
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
                        color: const Color(0xFFECECEC),
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
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 40,
                                  height: 27 / 40, // line-height from design
                                  color: Color(0xFFC2C2C2),
                                ),
                              ),
                            ),
                            
                            // Step description
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  step.description,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    height: 18 / 12, // line-height from design
                                    color: Color(0xFF797676),
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
                                  onChanged: (value) {
                                    setState(() {
                                      step.isCompleted = value ?? false;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF797676),
                                    width: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  step.duration,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    height: 20 / 13, // line-height from design
                                    color: Color(0xFF797676),
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
                    // Start cooking functionality would go here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF165932),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    minimumSize: const Size(232, 48),
                  ),
                  child: const Text(
                    'Начать готовить',
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
          ],
        ),
      ),
    );
  }
}