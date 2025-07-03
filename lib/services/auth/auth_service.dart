import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../../models/user.dart';

class AuthService {
  final ApiService _apiService;
  final Dio _dio;
  final String baseUrl = 'https://foodapi.dzolotov.pro';

  // Key for storing the auth token in SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Stream controller for broadcasting auth state changes
  final _authStateController = StreamController<User?>.broadcast();
  Stream<User?> get authStateChanges => _authStateController.stream;

  User? _currentUser;
  User? get currentUser => _currentUser;

  AuthService() : 
    _apiService = ApiService(),
    _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Initialize by checking for existing token
    _initializeUser();
  }

  // Initialize user from SharedPreferences if available
  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userData = prefs.getString(_userKey);

    if (token != null && userData != null) {
      try {
        final userJson = Map<String, dynamic>.from(
          Uri.dataFromString(userData).data! as Map
        );

        // Create a user object with the token
        final user = User.fromJson(userJson);
        _currentUser = user;
        _authStateController.add(_currentUser);

        // Set the token in the API service headers
        _dio.options.headers['Authorization'] = 'Bearer $token';
      } catch (e) {
        print('Error initializing user: $e');
        await logout();
      }
    } else {
      _authStateController.add(null);
    }
  }

  // Register a new user
  Future<User> register(String login, String password) async {
    try {
      final response = await _dio.post(
        '/user',
        data: {
          'login': login,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If registration is successful, login the user
        return await this.login(login, password);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 409) {
        throw Exception('User already exists');
      } else if (e.response != null) {
        throw Exception('Registration failed: ${e.response?.data['message'] ?? e.message}');
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    }
  }

  // Login an existing user
  Future<User> login(String login, String password) async {
    try {
      final response = await _dio.put(
        '/user',
        data: {
          'login': login,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;

        // Get user details using the token
        final user = await getUserProfile(login);

        // Save token and user data
        await _saveUserData(user, token);

        return user;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 403) {
        throw Exception('Invalid credentials');
      } else if (e.response != null) {
        throw Exception('Login failed: ${e.response?.data['message'] ?? e.message}');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    }
  }

  // Get user profile information
  Future<User> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/user/$userId');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to get user profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to get user profile: ${e.response?.data['message'] ?? e.message}');
      } else {
        throw Exception('Failed to get user profile: ${e.message}');
      }
    }
  }

  // Logout the current user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    _currentUser = null;
    _dio.options.headers.remove('Authorization');
    _authStateController.add(null);
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    // Save user data as a URI-encoded string
    final userWithToken = user.copyWith(token: token);
    await prefs.setString(_userKey, Uri.dataFromString(
      userWithToken.toJson().toString(),
      mimeType: 'application/json',
    ).toString());

    _currentUser = userWithToken;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _authStateController.add(_currentUser);
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Dispose resources
  void dispose() {
    _authStateController.close();
  }

  // Method to get the API service for direct access if needed
  ApiService getApiService() {
    return _apiService;
  }
}