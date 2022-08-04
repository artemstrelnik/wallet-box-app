import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/add_operation_screens/add_operation_screen.dart';
import 'package:wallet_box/app/screens/card_blank/card_blank.dart';

import 'add_card_screen_bloc.dart';
import 'add_card_screen_events.dart';
import 'add_card_screen_states.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  late UserNotifierProvider _userProvider;
  final ValueNotifier<LoadingState> _loadingState =
      ValueNotifier<LoadingState>(LoadingState.loading);

  final ValueNotifier<List<Loyalty>> _loyaltyList =
      ValueNotifier<List<Loyalty>>(<Loyalty>[]);
  final TextEditingController _controller = TextEditingController(text: "");
  final TextEditingController _controllerName = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();
  late String _token;

  @override
  void initState() {
    super.initState();
    context.read<AddCardScreenBloc>().add(
          PageOpenedEvent(),
        );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    return BlocListener<AddCardScreenBloc, AddCardScreenState>(
      listener: (context, state) {
        if (state is UpdateListLoyalty) {
          _token = state.token;
          if (state.list != null && state.list!.isNotEmpty) {
            _loyaltyList.value = state.list!;
            _loadingState.value = LoadingState.loaded;
          } else
            _loadingState.value = LoadingState.empty;
        }
        if (state is CreateCardState) {
          int count = 0;
          if (state.isHands) {
            Navigator.of(context).popUntil((_) => count++ >= 2);
          } else {
            Navigator.of(context).popUntil((_) => count++ >= 4);
          }
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => ScaffoldAppBarCustom(
        margin: false,
        actions: true,
        leading: true,
        title: "Выберите карту",
        actionsWidget: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () async {
              final Map<String, dynamic>? arr = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScannerScreen(isBarcode: true),
                ),
              );
              if (arr != null && arr.isNotEmpty) {
                if (arr["isBarcode"] as bool) {
                  _showCardList(
                    context,
                    code: arr["code"] as String,
                    codeType: arr["codeType"] as BarcodeType,
                  );
                } else {
                  _controller.text = arr["code"] as String;
                }
              }
            },
            child: Icon(
              Icons.camera_alt,
              color: StyleColorCustom()
                  .setStyleByEnum(context, StyleColorEnum.colorIcon),
            ),
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: _loadingState,
          builder: (BuildContext context, LoadingState _state, _) {
            switch (_state) {
              case LoadingState.empty:
                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: TextWidget(
                          padding: 0,
                          text: "На данный момент нет готовых бланков",
                          style: StyleTextCustom()
                              .setStyleByEnum(context, StyleTextEnum.bodyCard),
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              case LoadingState.loaded:
                return ValueListenableBuilder(
                  valueListenable: _loyaltyList,
                  builder: (BuildContext context, List<Loyalty> _list, _) =>
                      Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListView(
                            children: [
                              LayoutBuilder(
                                builder: (BuildContext context,
                                        BoxConstraints constraints) =>
                                    Column(
                                  children: _listCard(
                                    context,
                                    constraints,
                                    _list,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // const ContainerCustom(
                      //   margin: true,
                      //   width: true,
                      //   child: ButtonPink(
                      //     text: textString_27,
                      //     onPressed: onPressed,
                      //   ),
                      // )
                    ],
                  ),
                );
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  Widget _singleCard(
    double maxWidth,
    int index, {
    BuildContext? context,
    required Loyalty loyalty,
    bool isFinal = false,
    String? code,
    BarcodeType? codeType,
    String? path,
  }) =>
      GestureDetector(
        onTap: !isFinal
            ? () => _showBottom(context!, loyalty)
            : () {
                context!.read<AddCardScreenBloc>().add(
                      CreateCardLoyalty(
                        blankId: loyalty.id,
                        number: code!,
                        type: codeType!,
                        path: path,
                      ),
                    );
              },
        behavior: HitTestBehavior.translucent,
        child: Container(
          margin: EdgeInsets.only(top: index != 0 ? 16 : 0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            image: DecorationImage(
              image: _image(loyalty, path),
              fit: BoxFit.cover,
            ),
          ),
          height: maxWidth * .62,
        ),
      );

  List<Widget> _listCard(
      BuildContext context, BoxConstraints constraints, List<Loyalty> loyaltys,
      {bool isFinal = false, String? code, BarcodeType? codeType}) {
    final List<Widget> list = <Widget>[];

    list.add(GestureDetector(
      onTap: () async {
        final cameras = await availableCameras();
        final firstCamera = cameras.first;
        final isBack = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TakePictureScreen(
              camera: firstCamera,
              constraints: constraints,
              callBack: (String path) => context.read<AddCardScreenBloc>().add(
                    CreateCardLoyalty(
                      blankId: loyaltys.first.id,
                      number: code!,
                      type: codeType!,
                      isCustom: true,
                      path: path,
                    ),
                  ),
              isFinal: isFinal,
            ),
          ),
        );
        if (isBack != null) {
          _showBottom(
            context,
            _loyaltyList.value.first,
            path: isBack,
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          color: StyleColorCustom().setStyleByEnum(
            context,
            StyleColorEnum.secondaryBackground,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AssetsPath.plusBill),
            SizedBox(width: 8),
            TextWidget(
              padding: 0,
              text: "Добавить свою обложку",
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.textButtonCancel),
            ),
          ],
        ),
      ),
    ));

    loyaltys.asMap().forEach(
          (key, value) => list.add(
            _singleCard(
              constraints.maxWidth,
              key,
              loyalty: value,
              context: context,
              isFinal: isFinal,
              code: code,
              codeType: codeType,
            ),
          ),
        );
    return list;
  }

  void _showBottom(BuildContext _context, Loyalty loyalty, {String? path}) =>
      showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: StyleColorCustom().setStyleByEnum(
                    context, StyleColorEnum.secondaryBackground),
              ),
              padding: const EdgeInsets.all(16),
              //height: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) =>
                              Column(
                        children: [
                          _singleCard(
                            constraints.maxWidth,
                            0,
                            loyalty: loyalty,
                            path: path,
                          )
                        ],
                      ),
                    ),
                    TextFieldWidget(
                      textAlign: TextAlign.start,
                      autofocus: false,
                      textInputType: TextInputType.number,
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.neutralText),
                      labelText: "Номер карты",
                      fillColor: StyleColorCustom().setStyleByEnum(
                          context, StyleColorEnum.primaryBackground),
                      validation: (String? value) {
                        if (value != null && value.length < 4) {
                          return 'Не менее 4 символов';
                        }
                        return null;
                      },
                      controller: _controller,
                      contentPadding: const EdgeInsets.only(
                        left: 14.0,
                        bottom: 9.0,
                        top: 8.0,
                      ),
                      isDense: true,
                      paddingTop: EdgeInsets.only(top: 11),
                    ),
                    TextFieldWidget(
                      textAlign: TextAlign.start,
                      autofocus: false,
                      textInputType: TextInputType.multiline,
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.neutralText),
                      labelText: "Название карты (не обязательно)",
                      fillColor: StyleColorCustom().setStyleByEnum(
                          context, StyleColorEnum.primaryBackground),
                      validation: (String? value) {
                        if (value != null && value.length != 0) {
                          if (value.length < 2) {
                            return 'Не менее 4 символов';
                          }
                        }
                        return null;
                      },
                      controller: _controllerName,
                      contentPadding: const EdgeInsets.only(
                        left: 14.0,
                        bottom: 9.0,
                        top: 8.0,
                      ),
                      isDense: true,
                      paddingTop: EdgeInsets.only(top: 11),
                    ),
                    ButtonPink(
                      text: "Добавить",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _context.read<AddCardScreenBloc>().add(
                                CreateCardLoyalty(
                                    blankId: loyalty.id,
                                    number: _controller.text,
                                    name: _controllerName.text,
                                    path: path,
                                    isHands: true),
                              );
                        }
                      },
                      size: true,
                      padding: 12,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  void _showCardList(BuildContext _context,
          {required String code, required BarcodeType codeType}) =>
      showModalBottomSheet<void>(
        backgroundColor: Colors.red,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SafeArea(
            child: ScaffoldAppBarCustom(
              margin: false,
              header: "",
              body: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: StyleColorCustom().setStyleByEnum(
                      context, StyleColorEnum.secondaryBackground),
                ),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextWidget(
                        padding: 0,
                        text: "Выберите обложку для карты",
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.titleCard),
                      ),
                      SizedBox(height: 18),
                      Expanded(
                        child: SingleChildScrollView(
                          child: ValueListenableBuilder(
                            valueListenable: _loyaltyList,
                            builder: (BuildContext context, List<Loyalty> _list,
                                    _) =>
                                LayoutBuilder(
                              builder: (BuildContext context,
                                      BoxConstraints constraints) =>
                                  Column(
                                children: _listCard(
                                  _context,
                                  constraints,
                                  _list,
                                  isFinal: true,
                                  code: code,
                                  codeType: codeType,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  _image(Loyalty loyalty, String? path) => path == null
      ? NetworkImage(
          baseUrl +
              (path == null
                  ? "api/v1/image/content/" + loyalty.image!.name
                  : "api/v1/loyalty-card/custom-image/" + path),
          headers: <String, String>{"Authorization": "Bearer " + _token},
        )
      : FileImage(File(path));
}
