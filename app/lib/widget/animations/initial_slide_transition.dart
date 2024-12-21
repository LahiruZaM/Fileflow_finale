import 'package:common/util/sleep.dart'; // Utility to introduce delays
import 'package:flutter/material.dart';

/// A widget that slides in its child from an origin to a destination with a delay.
class InitialSlideTransition extends StatefulWidget {
  final Widget child; // The widget to be animated with a sliding effect
  final Offset origin; // The initial offset (starting position)
  final Offset destination; // The destination offset (final position)
  final Curve curve; // The curve used for the sliding animation (e.g., ease-out)
  final Duration duration; // The duration of the sliding animation
  final Duration delay; // The delay before starting the slide animation

  // Constructor with optional parameters for origin, destination, curve, and delay
  const InitialSlideTransition({
    required this.child,
    this.origin = Offset.zero, // Defaults to zero, meaning no initial offset
    this.destination = Offset.zero, // Defaults to zero, meaning no destination offset
    this.curve = Curves.easeOutCubic, // Defaults to an ease-out cubic curve
    required this.duration, // Duration for the animation
    this.delay = Duration.zero, // Delay before the animation starts
    super.key,
  });

  @override
  State<InitialSlideTransition> createState() => _InitialSlideTransitionState();
}

class _InitialSlideTransitionState extends State<InitialSlideTransition> {
  late Offset _offset; // The current offset value for the sliding animation

  @override
  void initState() {
    super.initState();
    
    // Set the initial offset to the provided origin
    _offset = widget.origin;
    
    // Ensure the widget is fully built before starting the animation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait for the specified delay before starting the slide
      await sleepAsync(widget.delay.inMilliseconds);
      
      // Check if the widget is still mounted before updating the state
      if (!mounted) {
        return;
      }
      
      // Change the offset to the destination after the delay
      setState(() {
        _offset = widget.destination;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Animate the sliding of the child widget from origin to destination with the specified curve and duration
    return AnimatedSlide(
      offset: _offset, // Current offset value that determines the position
      curve: widget.curve, // The curve for the animation (e.g., ease-out cubic)
      duration: widget.duration, // The duration of the slide animation
      child: widget.child, // The widget to be animated
    );
  }
}
