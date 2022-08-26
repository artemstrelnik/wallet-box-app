import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum AnimationTypeDownToUp { opacity, translateY }

class DownToUp extends StatelessWidget {
  final double delay;
  final Widget child;

  const DownToUp({Key? key, required this.delay, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween(AnimationTypeDownToUp.opacity, Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800))
      ..tween(AnimationTypeDownToUp.translateY, Tween(begin: 100.0, end: 0.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutExpo);
    return PlayAnimationBuilder<Movie>(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, value, _) => Opacity(
        opacity: value.get(AnimationTypeDownToUp.opacity),
        child: Transform.translate(
          offset: Offset(0, value.get(AnimationTypeDownToUp.translateY)),
          child: child,
        ),
      ),
    );
  }
}
