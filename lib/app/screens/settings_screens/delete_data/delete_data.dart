import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/src/provider.dart';
import 'package:screen_loader/screen_loader.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/data_time.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';

import 'delete_data_bloc.dart';
import 'delete_data_events.dart';
import 'delete_data_states.dart';

class DeleteDataScreen extends StatefulWidget {
  @override
  _DeleteDataScreenState createState() => _DeleteDataScreenState();
}

class _DeleteDataScreenState extends State<DeleteDataScreen> with ScreenLoader {
  late UserNotifierProvider _userProvider;
  DateTime _start = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  DateTime _end = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  loader() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ConstContext.lightMode(context)
              ? CustomColors.lightPrimaryBackground
              : CustomColors.darkPrimaryBackground,
        ),
        child: CircularProgressIndicator(
          color: !ConstContext.lightMode(context)
              ? CustomColors.lightPrimaryBackground
              : CustomColors.darkPrimaryBackground,
        ),
        width: 100,
        height: 100,
        alignment: Alignment.center,
      ),
    );
  }

  @override
  loadingBgBlur() => 10.0;

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    return BlocListener<DeleteDataBloc, DeleteDataState>(
      listener: (context, state) {
        if (state is ListLoadingOpacityState) {
          startLoading();
        }
        if (state is ListLoadingOpacityHideState) {
          stopLoading();
        }
        if (state is ShowMessage) {
          _showMyDialog(context, title: state.title, message: state.message);
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => loadableWidget(
        child: ScaffoldAppBarCustom(
          header: textString_47,
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
                text: textString_48,
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.neutralText),
                align: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ButtonCancel(
                      text: textString_11,
                      onPressed: () => Navigator.pop(context)),
                  ButtonPink(
                    text: textString_10,
                    onPressed: () {
                      context.read<DeleteDataBloc>().add(
                            CleanUserData(
                              start: _start.toIso8601String() + "Z",
                              end: _end.toIso8601String() + "Z",
                              uid: _userProvider.user!.id,
                            ),
                          );
                    },
                  ),
                ],
              ),
              ButtonNoBackground(
                text: textString_49,
                onPressed: () => context.read<DeleteDataBloc>().add(
                      CleanUserData(
                        start: DateTime(DateTime.now().year - 70,
                                    DateTime.now().month, DateTime.now().day)
                                .toIso8601String() +
                            "Z",
                        end: _end.toIso8601String() + "Z",
                        uid: _userProvider.user!.id,
                      ),
                    ),
              ),
            ],
          ),
        ),
      );

  Future<void> _showMyDialog(context,
      {String? title, required String message}) async {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? "Произошла ошибка"),
        content: Text(message.split(":").last.trim()),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Понятно'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
