import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    Key? key,
    required this.textInputType,
    required this.style,
    required this.labelText,
    required this.fillColor,
    required this.autofocus,
    this.filteringTextInputFormatter,
    this.icon,
    this.colorIcon,
    this.textAlign,
    this.turnColor,
    this.validation,
    this.controller,
    this.contentPadding =
        const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
    this.isDense = false,
    this.paddingTop = const EdgeInsets.only(top: 10.0),
    this.readOnly = false,
    this.obscureText = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.singleLines = false,
    this.textInputAction,
    this.underLineStyle = false,
    this.isSearch = false,
  }) : super(key: key);

  final TextInputAction? textInputAction;
  final TextInputType textInputType;
  final TextStyle style;
  final String labelText;
  final Color fillColor;
  final Color? colorIcon;
  final IconData? icon;
  final bool autofocus;
  final TextAlign? textAlign;
  final List<TextInputFormatter>? filteringTextInputFormatter;
  final bool? turnColor;
  final Function(String? value)? validation;
  final TextEditingController? controller;
  final EdgeInsets? contentPadding;
  final bool isDense;
  final EdgeInsets paddingTop;
  final bool readOnly;
  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool singleLines;
  final bool underLineStyle;
  final bool isSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: paddingTop,
      child: TextFormField(
        textInputAction: textInputAction ?? TextInputAction.next,
        obscureText: obscureText,
        enableSuggestions: enableSuggestions,
        autocorrect: autocorrect,
        readOnly: readOnly,
        controller: controller ?? TextEditingController(),
        validator: (String? value) => validation?.call(value),
        minLines: 1,
        maxLines: obscureText || singleLines ? 1 : 8,
        textAlign: textAlign != null ? textAlign! : TextAlign.left,
        autofocus: autofocus,
        style: style,
        keyboardType: textInputType,
        inputFormatters: filteringTextInputFormatter,
        decoration: underLineStyle
            ? InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: StyleColorCustom()
                        .setStyleByEnum(context, StyleColorEnum.neitralColor),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: StyleColorCustom()
                        .setStyleByEnum(context, StyleColorEnum.neitralColor),
                  ),
                ),
                fillColor: fillColor,
                hintStyle: style,
                filled: true,
                contentPadding: contentPadding,
                hintText: labelText,
                isDense: isDense,
              )
            : (icon != null
                ? InputDecoration(
                    isDense: isDense,
                    border: InputBorder.none,
                    hintText: labelText,
                    hintStyle: style,
                    prefixIcon: Icon(
                      icon,
                      color: colorIcon,
                    ),
                    filled: true,
                    fillColor: fillColor,
                    contentPadding: contentPadding,
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  )
                : InputDecoration(
                    isDense: isDense,
                    border: InputBorder.none,
                    hintText: labelText,
                    hintStyle: style,
                    filled: true,
                    fillColor: fillColor,
                    contentPadding: contentPadding,
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    suffixIcon: isSearch
                        ? IconButton(
                            onPressed: () => controller?.clear(),
                            icon: Icon(
                              Icons.clear,
                              color: CustomColors.neutralText,
                            ),
                          )
                        : null,
                  )),
      ),
    );
  }
}
