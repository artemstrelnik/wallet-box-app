import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_box/app/core/styles/style_color_custom.dart';

import '../../../core/themes/colors.dart';

Widget svgIcon(String path, BuildContext context, {Color? color}) => SizedBox(
      height: 22,
      width: 22,
      child: SvgPicture.network(
        path, //response.body,
        color: color ?? Colors.white,
      ),
    );
// FutureBuilder(
//   future: _svgLoading(path, color, context),
//   builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
//     if (snapshot.connectionState == ConnectionState.done &&
//         snapshot.data != null)
//       return snapshot.data!;
//     else
//       return const SizedBox(
//         child: CircularProgressIndicator(),
//         height: 20,
//         width: 20,
//       );
//   },
// );

Future<Widget> _svgLoading(
    String path, Color? color, BuildContext context) async {
  var url = Uri.parse(path);
  var response = await http.get(url);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return SizedBox(
      height: 22,
      width: 22,
      child: SvgPicture.string(
        path, //response.body,
        color: color ?? Colors.white,
      ),
    );
  }
  return Container();
}
