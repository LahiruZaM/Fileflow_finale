
import 'package:common/util/sleep.dart'; // Utility for adding delays
import 'package:flutter/material.dart';

/// A widget that fades in its child with a delay and duration.
class InitialFadeTransition extends StatefulWidget {
  final Widget child; // The widget to be faded in
  final Duration duration; // The duration of the fade-in animation
  final Duration delay; // The delay before starting the fade-in animation

  // Constructor with optional delay (defaults to zero)
  const InitialFadeTransition({
    required this.child,
    required this.duration,
    this.delay = Duration.zero,
    super.key,
  });

  @override
  State<InitialFadeTransition> createState() => _InitialFadeTransitionState();
}

class _InitialFadeTransitionState extends State<InitialFadeTransition> {
  double _opacity = 0; // Initial opacity set to 0 (fully transparent)

  @override
  void initState() {
    super.initState();
    
    // Wait for the widget to build, then start the fade-in with delay
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait for the specified delay before starting the fade
      await sleepAsync(widget.delay.inMilliseconds);
      
      // Check if the widget is still in the widget tree before updating the state
      if (!mounted) {
        return;
      }
      
      // Update opacity to 1 (fully opaque) after the delay
      setState(() {
        _opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Animate the opacity change over the specified duration
    return AnimatedOpacity(
      opacity: _opacity, // The current opacity value (changes from 0 to 1)
      duration: widget.duration, // The duration of the fade-in animation
      child: widget.child, // The widget to fade in
    );
  }
}
