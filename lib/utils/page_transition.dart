import 'package:flutter/material.dart';

/// Custom page route that provides various transition animations
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;
  final Curve curve;
  final Duration duration;
  final Duration reverseDuration;

  CustomPageRoute({
    required this.page,
    this.transitionType = TransitionType.fade,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            switch (transitionType) {
              case TransitionType.fade:
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: child,
                );
              case TransitionType.rightToLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case TransitionType.leftToRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case TransitionType.topToBottom:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, -1.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case TransitionType.bottomToTop:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case TransitionType.scale:
                return ScaleTransition(
                  scale: curvedAnimation,
                  child: child,
                );
              case TransitionType.rotate:
                return RotationTransition(
                  turns: curvedAnimation,
                  child: child,
                );
              case TransitionType.size:
                return SizeTransition(
                  sizeFactor: curvedAnimation,
                  child: child,
                );
              case TransitionType.fadeAndScale:
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.8,
                      end: 1.0,
                    ).animate(curvedAnimation),
                    child: child,
                  ),
                );
            }
          },
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
        );
}

/// Enum defining the available transition types
enum TransitionType {
  fade,
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
  scale,
  rotate,
  size,
  fadeAndScale,
}
