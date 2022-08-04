import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/screens/auth_screens/support/support_screen.dart';
import 'package:wallet_box/app/screens/auth_screens/support/support_screen_bloc.dart';

class ScaffoldAppBarCustom extends StatelessWidget {
  const ScaffoldAppBarCustom({
    Key? key,
    required this.body,
    this.title,
    // required this.titleStyle,
    this.actions,
    this.leading,
    this.header,
    this.margin,
    this.appBar,
    this.icon,
    this.svgIcon,
    this.minimum = const EdgeInsets.only(left: 20, right: 20),
    this.height = 30,
    this.actionsWidget,
    this.onTap,
  }) : super(key: key);

  final Widget body;
  final String? title, header, icon;
  // final TextStyle titleStyle, headerStyle;
  final bool? actions, leading, margin, appBar;
  final Widget? svgIcon;
  final EdgeInsets minimum;
  final double height;
  final Widget? actionsWidget;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: appBar == null
          ? AppBar(
              leading: leading != null
                  ? GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: StyleColorCustom()
                            .setStyleByEnum(context, StyleColorEnum.colorIcon),
                      ),
                    )
                  : null,
              title: title != null
                  ? TextWidget(
                      padding: 0,
                      text: title!,
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.appBarTitle),
                    )
                  : null,
              actions: actions != null
                  ? [
                      actionsWidget ??
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (context) => SupprotScreenBloc(),
                                    child: SupprotScreen(),
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: StyleColorCustom().setStyleByEnum(
                                    context, StyleColorEnum.colorIcon),
                              ),
                            ),
                          ),
                    ]
                  : [],
              bottom: header != null
                  ? PreferredSize(
                      preferredSize: Size(
                          MediaQuery.of(context).size.width,
                          actions != null || title != null || leading != null
                              ? height
                              : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextWidget(
                              padding: 0,
                              text: header!,
                              style: StyleTextCustom().setStyleByEnum(
                                  context, StyleTextEnum.header),
                            ),
                          ),
                          icon != null
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Image.asset(icon!, width: 32),
                                )
                              : Container(),
                          svgIcon != null ? svgIcon! : Container(),
                        ],
                      ),
                    )
                  : null,
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: margin == null
          ? SafeArea(
              minimum: minimum,
              child: body,
            )
          : SafeArea(child: body),
      floatingActionButton: onTap != null
          ? FloatingActionButton(
              onPressed: onTap,
            )
          : const SizedBox(),
    );
  }
}
