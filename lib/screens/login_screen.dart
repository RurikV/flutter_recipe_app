import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';
import '../services/auth_service.dart';
import '../widgets/navigation/auth_bottom_navigation_bar.dart';
import 'registration_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Dispatch login success action to update Redux state
      StoreProvider.of<AppState>(context, listen: false)
          .dispatch(LoginSuccessAction(user));

      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF2ECC71), // Green background as per design
      bottomNavigationBar: const AuthBottomNavigationBar(isLoginActive: true),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Center(
              child: SizedBox(
                width: orientation == Orientation.landscape
                    ? MediaQuery.of(context).size.width * 0.5
                    : MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // App title
                      Padding(
                        padding: const EdgeInsets.only(top: 80.0),
                        child: Text(
                          'Otus.Food',
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 30,
                            height: 23/30, // line-height / font-size
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Username field
                      Padding(
                        padding: const EdgeInsets.only(top: 60.0, left: 40.0, right: 40.0),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              // User icon
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                              // Username input
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 13.0),
                                  child: TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      hintText: 'логин',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: const Color(0xFFC2C2C2),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Password field
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 40.0, right: 40.0),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              // Password icon
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0),
                                child: Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                              // Password input
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 13.0),
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'пароль',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: const Color(0xFFC2C2C2),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Error message
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      // Login button
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0),
                        child: GestureDetector(
                          onTap: _isLoading ? null : _login,
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF165932), // Dark green as per design
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Войти',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      // Registration link
                      Padding(
                        padding: const EdgeInsets.only(top: 60.0, bottom: 40.0),
                        child: GestureDetector(
                          onTap: _navigateToRegistration,
                          child: const Text(
                            'Зарегистрироваться',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
