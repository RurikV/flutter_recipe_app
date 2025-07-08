class RecipeStep {
  final int id;
  final String name;
  final String description;
  final String duration;
  final bool isCompleted;

  RecipeStep({
    this.id = 0,
    required this.name,
    required this.description,
    required this.duration,
    this.isCompleted = false,
  });


  // Creates a copy of the recipe step with the given fields replaced with the new values
  RecipeStep copyWith({
    int? id,
    String? name,
    String? description,
    String? duration,
    bool? isCompleted,
  }) {
    return RecipeStep(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
