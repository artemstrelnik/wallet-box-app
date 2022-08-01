import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/data_time.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/screens/settings_screens/export_screen/export_screen_bloc.dart';
import 'package:wallet_box/app/screens/settings_screens/export_screen/export_screen_events.dart';
import 'package:wallet_box/app/screens/settings_screens/export_screen/export_screen_states.dart';
import 'package:open_file/open_file.dart';

class ExportScreen extends StatelessWidget {
  ExportScreen({Key? key}) : super(key: key);

  DateTime _start = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  DateTime _end = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportBloc, ExportScreenState>(
      listener: (context, state) async {
        if (state is CsvOpenFile) {
          final Uri uri = Uri.file(state.path);

          if (await File(uri.toFilePath()).exists()) {
            final message = await OpenFile.open(state.path);
          }
        }
      },
      child: _scaffold(context),
    );
  }

  _scaffold(BuildContext context) {
    return ScaffoldAppBarCustom(
      header: textString_43,
      actions: true,
      leading: true,
      body: Column(
        children: [
          ContainerCustom(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                    padding: 0,
                    text: textString_44,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)),
                DataTimeWidget(
                  now: _start,
                  updateDate: (value) => _start = value,
                ),
              ],
            ),
          ),
          ContainerCustom(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                    padding: 0,
                    text: textString_45,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)),
                DataTimeWidget(
                  now: _end,
                  updateDate: (value) => _end = value,
                ),
              ],
            ),
          ),
          TextWidget(
            text: textString_46,
            style: StyleTextCustom()
                .setStyleByEnum(context, StyleTextEnum.neutralText),
            align: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonCancel(
                  text: textString_11, onPressed: () => Navigator.pop(context)),
              ButtonPink(
                text: textString_10,
                onPressed: () => context.read<ExportBloc>().add(
                      ExportCSVFileEvent(
                        start: _start,
                        end: _end,
                      ),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
