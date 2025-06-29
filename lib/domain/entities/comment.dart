class Comment {
  final String id;
  final String authorName;
  final String text;
  final String date;

  Comment({
    required this.id,
    required this.authorName,
    required this.text,
    required this.date,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      text: json['text'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'text': text,
      'date': date,
    };
  }
}