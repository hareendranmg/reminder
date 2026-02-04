import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final AnimationController controller;

  const HomeFAB({super.key, required this.onPressed, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
          onPressed: onPressed,
          icon: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: controller.value * 0.5,
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              );
            },
          ),
          label: Text(
            'New Reminder',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 2,
          highlightElevation: 4,
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}
