import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({
    Key? key,
    required this.text,
    required this.style,
    this.align,
    this.padding,
    this.overflow = TextOverflow.visible,
  }) : super(key: key);
  final String text;
  final TextStyle style;
  final TextAlign? align;
  final double? padding;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: padding ?? 10),
      child: Text(
        text,
        textAlign: align ?? TextAlign.left,
        style: style,
        overflow: overflow,
      ),
    );
  }
}
