import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const RiveFavoriteButton({
    Key? key,
    required this.isFavorite,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<RiveFavoriteButton> createState() => _RiveFavoriteButtonState();
}

class _RiveFavoriteButtonState extends State<RiveFavoriteButton> {
  // Controllers for the Rive animation
  StateMachineController? _controller;
  SMIBool? _isFavoriteInput;
  SMITrigger? _pulseInput;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RiveFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger the pulse animation when the favorite state changes
    if (oldWidget.isFavorite != widget.isFavorite && widget.isFavorite) {
      _pulseInput?.fire();
    }
    // Update the favorite state in the Rive animation
    if (_isFavoriteInput != null) {
      _isFavoriteInput!.value = widget.isFavorite;
    }
  }

  void _onRiveInit(Artboard artboard) {
    // Get the state machine controller
    final controller = StateMachineController.fromArtboard(
      artboard,
      'heart_state_machine', // The name of the state machine in the Rive file
    );

    if (controller != null) {
      artboard.addController(controller);
      _controller = controller;

      // Get the inputs
      _isFavoriteInput = controller.findSMI('isFavorite') as SMIBool?;
      _pulseInput = controller.findSMI('pulse') as SMITrigger?;

      // Set the initial state
      if (_isFavoriteInput != null) {
        _isFavoriteInput!.value = widget.isFavorite;
      }

      // Trigger the pulse animation if the heart is already favorite
      if (widget.isFavorite) {
        _pulseInput?.fire();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();

        // Trigger the pulse animation if the heart is becoming favorite
        if (!widget.isFavorite) {
          _pulseInput?.fire();
        }
      },
      child: SizedBox(
        width: 30,
        height: 30,
        child: Stack(
          children: [
            // Fallback icon that's always visible behind the Rive animation
            Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? const Color(0xFF2ECC71) : Colors.grey,
              size: 30,
            ),
            // Rive animation on top
            RiveAnimation.asset(
              'assets/animations/heart.riv',
              fit: BoxFit.contain,
              onInit: _onRiveInit,
            ),
          ],
        ),
      ),
    );
  }
}
