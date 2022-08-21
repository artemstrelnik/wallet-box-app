import 'package:flutter/material.dart';

import '../styles/style_color_custom.dart';

class CustomBottomSheet {
  static Future customBottomSheet(BuildContext context, Widget body) async {
    return await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      backgroundColor: StyleColorCustom().setStyleByEnum(
        context,
        StyleColorEnum.secondaryBackground,
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: body,
      ),
    );
  }

  static Container topDividerBottomSheet() {
    return Container(
      height: 4,
      width: 40,
      margin: EdgeInsets.only(top: 10.0,bottom: 30.0),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
  }
}
