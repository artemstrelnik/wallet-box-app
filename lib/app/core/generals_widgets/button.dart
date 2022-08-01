import 'package:flutter/material.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';

class ButtonBlue extends StatelessWidget {
  const ButtonBlue({
    Key? key,
    required this.text,
    required this.onPressed,
    this.size,
    this.padding,
    this.widthCustom,
  }) : super(key: key);
  final String text;
  final Function onPressed;
  final bool? size;
  final double? padding;
  final double? widthCustom;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: padding == null ? 20.0 : padding!),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.textButton),
          primary: CustomColors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          minimumSize: Size(
              size == null
                  ? (widthCustom ?? 150)
                  : MediaQuery.of(context).size.width,
              40),
        ),
        onPressed: () => onPressed(),
        child: Text(
          text,
          style: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.textButton),
        ),
      ),
    );
  }
}

class ButtonPink extends StatelessWidget {
  const ButtonPink({
    Key? key,
    required this.text,
    required this.onPressed,
    this.size,
    this.padding,
    this.widthCustom,
  }) : super(key: key);
  final String text;
  final Function onPressed;
  final bool? size;
  final double? padding;
  final double? widthCustom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: padding == null ? 20.0 : padding!),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.textButton),
          primary: CustomColors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          minimumSize: Size(
              size == null
                  ? (widthCustom ?? 150)
                  : MediaQuery.of(context).size.width,
              40),
        ),
        onPressed: () => onPressed(),
        child: Text(
          text,
          style: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.textButton),
        ),
      ),
    );
  }
}

class ButtonCancel extends StatelessWidget {
  const ButtonCancel({
    Key? key,
    required this.text,
    required this.onPressed,
    this.size,
    this.padding,
    this.widthCustom,
  }) : super(key: key);
  final String text;
  final Function onPressed;
  final bool? size;
  final double? padding;
  final double? widthCustom;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: padding == null ? 20.0 : padding!),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.textButtonCancel),
          primary: StyleColorCustom()
              .setStyleByEnum(context, StyleColorEnum.buttonCancel),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          minimumSize: Size(
              size == null
                  ? (widthCustom ?? 150)
                  : MediaQuery.of(context).size.width,
              40),
        ),
        onPressed: () => onPressed(),
        child: Text(
          text,
          style: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.textButtonCancel),
        ),
      ),
    );
  }
}

class ButtonNoBackground extends StatelessWidget {
  const ButtonNoBackground(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.size,
      this.padding})
      : super(key: key);
  final String text;
  final Function onPressed;
  final bool? size;
  final double? padding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: padding == null ? 20.0 : padding!),
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.textButtonNoBackground),
          primary: StyleColorCustom()
              .setStyleByEnum(context, StyleColorEnum.buttonCancel),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          minimumSize: const Size(150, 40),
        ),
        onPressed: () => onPressed(),
        child: Text(
          text,
          style: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.textButtonNoBackground),
        ),
      ),
    );
  }
}

class ButtonWhite extends StatelessWidget {
  const ButtonWhite({
    Key? key,
    required this.text,
    required this.onPressed,
    this.size,
    this.padding,
    this.widthCustom,
    this.customText,
  }) : super(key: key);
  final String text;
  final Function onPressed;
  final bool? size;
  final double? padding;
  final double? widthCustom;
  final Widget? customText;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: padding == null ? 20.0 : padding!),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.textButtonCancel),
          primary: CustomColors.lightSecondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          minimumSize: Size(
              size == null
                  ? (widthCustom ?? 150)
                  : MediaQuery.of(context).size.width,
              40),
        ),
        onPressed: () => onPressed(),
        child: customText ??
            Text(
              text,
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.textButtonCancel)
                  .copyWith(color: CustomColors.lightSecondaryText),
            ),
      ),
    );
  }
}
