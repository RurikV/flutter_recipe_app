import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A stateful widget that animates between checked and unchecked states
class AnimatedStepCheckbox extends StatefulWidget {
  final bool isCompleted;
  final bool isCookingMode;
  final ValueChanged<bool> onChanged;

  const AnimatedStepCheckbox({
    super.key,
    required this.isCompleted,
    required this.isCookingMode,
    required this.onChanged,
  });

  @override
  State<AnimatedStepCheckbox> createState() => _AnimatedStepCheckboxState();
}

class _AnimatedStepCheckboxState extends State<AnimatedStepCheckbox> with SingleTickerProviderStateMixin {
  // Animation controller for explicit animation
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize with the current state
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: widget.isCompleted ? 1.0 : 0.0,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedStepCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when the isCompleted state changes
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder for explicit animation
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Checkbox(
              value: widget.isCompleted,
              onChanged: widget.isCookingMode ? (value) {
                final newValue = value ?? false;
                // Animate the checkbox before calling the parent's callback
                if (newValue) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
                widget.onChanged(newValue);
              } : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              side: BorderSide(
                color: widget.isCookingMode ? AppColors.checkboxActiveCooking : AppColors.checkboxInactive,
                width: 4,
              ),
            ),
          ),
        );
      },
    );
  }
}
