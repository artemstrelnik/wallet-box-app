import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CustomAnimationList extends StatelessWidget {
  final int position;
  final Widget child;

  const CustomAnimationList({
    Key? key,
    required this.position,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: position,
      delay: Duration(milliseconds: position == 0 ? 100 : 150),
      child: SlideAnimation(
        duration: Duration(milliseconds: position == 0 ? 2000:  2500),
        curve: Curves.fastLinearToSlowEaseIn,
        horizontalOffset: 30.0,
        verticalOffset: 300.0,
        child: FlipAnimation(
          duration: Duration(milliseconds: position == 0 ? 2200: 2500),
          curve: Curves.fastLinearToSlowEaseIn,
          flipAxis: FlipAxis.y,
          child: child,
        ),
      ),
    );
  }
}
