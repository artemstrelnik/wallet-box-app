import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum AnimationType { opacity, translateX }

class RightToLeft extends StatelessWidget {
  final double delay;
  final Widget child;

  const RightToLeft({Key? key, required this.delay, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween(AnimationType.opacity, Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.fastOutSlowIn)
      ..tween(AnimationType.translateX, Tween(begin: 100.0, end: 0.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.fastOutSlowIn);
    return PlayAnimationBuilder<Movie>(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, value, _) => Opacity(
        opacity: value.get(AnimationType.opacity),
        child: Transform.translate(
          offset: Offset(value.get(AnimationType.translateX), 0),
          child: child,
        ),
      ),
    );
  }
}
