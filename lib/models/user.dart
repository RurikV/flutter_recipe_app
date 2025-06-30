class User {
  final int id;
  final String login;
  final String? password;
  final String? token;
  final String? avatar;
  final List<dynamic>? userFreezer;
  final List<dynamic>? favoriteRecipes;
  final List<dynamic>? comments;

  User({
    required this.id,
    required this.login,
    this.password,
    this.token,
    this.avatar,
    this.userFreezer,
    this.favoriteRecipes,
    this.comments,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      login: json['login'] as String,
      password: json['password'] as String?,
      token: json['token'] as String?,
      avatar: json['avatar'] as String?,
      userFreezer: json['userFreezer'] as List<dynamic>?,
      favoriteRecipes: json['favoriteRecipes'] as List<dynamic>?,
      comments: json['comments'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      if (password != null) 'password': password,
      if (token != null) 'token': token,
      if (avatar != null) 'avatar': avatar,
      if (userFreezer != null) 'userFreezer': userFreezer,
      if (favoriteRecipes != null) 'favoriteRecipes': favoriteRecipes,
      if (comments != null) 'comments': comments,
    };
  }

  User copyWith({
    int? id,
    String? login,
    String? password,
    String? token,
    String? avatar,
    List<dynamic>? userFreezer,
    List<dynamic>? favoriteRecipes,
    List<dynamic>? comments,
  }) {
    return User(
      id: id ?? this.id,
      login: login ?? this.login,
      password: password ?? this.password,
      token: token ?? this.token,
      avatar: avatar ?? this.avatar,
      userFreezer: userFreezer ?? this.userFreezer,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      comments: comments ?? this.comments,
    );
  }
}
