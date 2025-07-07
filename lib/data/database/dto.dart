
// Custom class for Comment data since the generated class is not available
class CommentData {
  final String id;
  final String recipeUuid;
  final String authorName;
  final String text;
  final String date;

  CommentData({
    required this.id,
    required this.recipeUuid,
    required this.authorName,
    required this.text,
    required this.date,
  });

  // Factory constructor to create a CommentData from a database row
  factory CommentData.fromData(Map<String, dynamic> data) {
    return CommentData(
      id: data['id'] as String,
      recipeUuid: data['recipe_uuid'] as String,
      authorName: data['author_name'] as String,
      text: data['text'] as String,
      date: data['date'] as String,
    );
  }
}