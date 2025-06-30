class User {
  final String id;
  final String username;
  final String email;
  final String? name;
  final String? avatar;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.avatar,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (token != null) 'token': token,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? avatar,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
    );
  }
}
