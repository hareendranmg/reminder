import 'package:flutter/material.dart';

class AlertAnimatedIcon extends StatelessWidget {
  final Animation<double> animation;

  const AlertAnimatedIcon({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final scale = 1.0 + (animation.value * 0.1);
          final opacity = 0.3 + (animation.value * 0.3);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Transform.scale(
                scale: scale * 1.4,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withAlpha(
                      (opacity * 0.3 * 255).toInt(),
                    ),
                  ),
                ),
              ),
              // Inner pulse ring
              Transform.scale(
                scale: scale * 1.2,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withAlpha(
                      (opacity * 0.5 * 255).toInt(),
                    ),
                  ),
                ),
              ),
              // Icon container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(77),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
