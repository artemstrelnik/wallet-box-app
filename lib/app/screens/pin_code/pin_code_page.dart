
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';
import 'package:wallet_box/app/bloc/my_app_bloc.dart';
import 'package:wallet_box/app/bloc/my_app_events.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/pin_code/pin_code_event.dart';

import 'pin_code_bloc.dart';
import 'pin_code_state.dart';
import 'package:screen_loader/screen_loader.dart';

class PinCodePage extends StatefulWidget {
  const PinCodePage({Key? key, this.isStart = false}) : super(key: key);
  final bool isStart;
  @override
  _PinCodePageState createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> with ScreenLoader {
  final ValueNotifier<List<String>> _pinCodeSymbols =
      ValueNotifier<List<String>>(<String>[]);
  late UserNotifierProvider _userProvider;

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
    return BlocListener<PinCodeBloc, PinCodeState>(
      listener: (context, state) {
        if (state is ListLoadingOpacityState) {
          startLoading();
        }
        if (state is ListLoadingOpacityHideState) {
          stopLoading();
        }
        if (state is CodesEqualState) {
          context.read<MyAppBloc>().add(
                UserAuthenticatedEvent(
                  code: _pinCodeSymbols.value.join(""),
                ),
              );
        }
        if (state is ClearCodeState) {
          _pinCodeSymbols.value = [];
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) {
    return loadableWidget(
      child: ScaffoldAppBarCustom(
        header: textString_35,
        leading: widget.isStart ? null : true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Введите новый пин-код",
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.bodyCard),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 23, bottom: 21),
              child: ValueListenableBuilder(
                valueListenable: _pinCodeSymbols,
                builder: (BuildContext context, List<String> _list, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (int index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          color: (index + 1 <= _list.length)
                              ? Colors.red
                              : CustomColors.dotPinCode,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(240, 24, 123, 1),
                      Color.fromRGBO(106, 130, 251, 1),
                    ],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dialButton(context, text: "1"),
                  _dialButton(context, text: "2"),
                  _dialButton(context, text: "3"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dialButton(context, text: "4"),
                  _dialButton(context, text: "5"),
                  _dialButton(context, text: "6"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dialButton(context, text: "7"),
                  _dialButton(context, text: "8"),
                  _dialButton(context, text: "9"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 50),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dialButton(
                    context,
                    text: "",
                    isSymbol: false,
                    icon: SvgPicture.asset(AssetsPath.delete),
                  ),
                  _dialButton(context, text: "0"),
                  _dialButton(
                    context,
                    text: "",
                    isSymbol: false,
                    icon: SvgPicture.asset(AssetsPath.delete),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialButton(BuildContext context,
          {required String text, bool isSymbol = true, Widget? icon}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: GestureDetector(
          onTap: () {
            if (_pinCodeSymbols.value.length == 4) return;
            if (isSymbol) {
              List<String> _list = List.of(_pinCodeSymbols.value);
              _list.add(text);
              _pinCodeSymbols.value = _list;
              if (_pinCodeSymbols.value.length == 4) {
                context.read<PinCodeBloc>().add(
                      CodeEnteredEvent(
                        code: _pinCodeSymbols.value.join(""),
                        pinCode: _userProvider.user!.pinCode,
                      ),
                    );
              }
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 5),
                  color: CustomColors.dialButtonShadow,
                  blurRadius: 15,
                )
              ],
            ),
            height: 50,
            width: 50,
            child: Center(
              child: isSymbol
                  ? Text(
                      text,
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.bodyCard)
                          .copyWith(fontSize: 24),
                    )
                  : icon ?? Container(),
            ),
          ),
        ),
      );
}
