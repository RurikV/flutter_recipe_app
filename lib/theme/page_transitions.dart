import 'package:flutter/material.dart';

/// Custom page route that uses a fade transition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// Helper class to provide custom page transitions for the app
class AppPageTransitions {
  /// Creates a fade transition route to the given page
  static Route<T> fadeTransition<T>(Widget page) {
    return FadePageRoute<T>(page: page);
  }
}