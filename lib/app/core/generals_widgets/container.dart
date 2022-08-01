import 'package:flutter/material.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';

class ContainerCustom extends StatelessWidget {
  const ContainerCustom({
    Key? key,
    required this.child,
    this.turnColor,
    this.gradient,
    this.margin,
    this.width,
    this.padding = const EdgeInsets.all(15),
  }) : super(key: key);
  final Widget child;
  final bool? turnColor;
  final bool? gradient;
  final bool? margin, width;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width != null ? MediaQuery.of(context).size.width : null,
      padding: padding,
      margin: margin == null
          ? const EdgeInsets.only(
              top: 10,
              bottom: 5,
            )
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: turnColor == null
            ? StyleColorCustom().setStyleByEnum(
                context,
                StyleColorEnum.secondaryBackground,
              )
            : StyleColorCustom().setStyleByEnum(
                context,
                StyleColorEnum.primaryBackground,
              ),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradient != null
              ? turnColor == null
                  ? CustomColors.listGradienAction
                  : CustomColors.listGradienDivider
              : turnColor == null
                  ? [
                      StyleColorCustom().setStyleByEnum(
                        context,
                        StyleColorEnum.secondaryBackground,
                      ),
                      StyleColorCustom().setStyleByEnum(
                        context,
                        StyleColorEnum.secondaryBackground,
                      )
                    ]
                  : [
                      StyleColorCustom().setStyleByEnum(
                        context,
                        StyleColorEnum.primaryBackground,
                      ),
                      StyleColorCustom().setStyleByEnum(
                        context,
                        StyleColorEnum.primaryBackground,
                      )
                    ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}
