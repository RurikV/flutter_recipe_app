class RecipeStep {
  final String description;
  final String duration;
  final bool isCompleted;

  RecipeStep({
    required this.description,
    required this.duration,
    this.isCompleted = false,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      description: json['description'] as String,
      duration: json['duration'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'duration': duration,
      'isCompleted': isCompleted,
    };
  }

  // Creates a copy of the recipe step with the given fields replaced with the new values
  RecipeStep copyWith({
    String? description,
    String? duration,
    bool? isCompleted,
  }) {
    return RecipeStep(
      description: description ?? this.description,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}