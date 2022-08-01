import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/my_loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';

import 'detail_card_screen_bloc.dart';
import 'detail_card_screen_events.dart';
import 'detail_card_screen_states.dart';
import 'package:barcode/barcode.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'dart:io';

class DetailCardScreen extends StatefulWidget {
  @override
  _DetailCardScreenState createState() => _DetailCardScreenState();
}

class _DetailCardScreenState extends State<DetailCardScreen> {
  late UserNotifierProvider _userProvider;
  final ValueNotifier<LoadingState> _loadingState =
      ValueNotifier<LoadingState>(LoadingState.loading);

  final ValueNotifier<MyLoyaltyData?> _loyaltyList =
      ValueNotifier<MyLoyaltyData?>(null);
  late String _token;

  @override
  void initState() {
    super.initState();
    context.read<DetailCardScreenBloc>().add(
          PageOpenedEvent(),
        );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    return BlocListener<DetailCardScreenBloc, DetailCardScreenState>(
      listener: (context, state) {
        if (state is UpdateCardLoyalty) {
          _token = state.token;
          if (state.card != null) {
            _loadingState.value = LoadingState.loaded;
            _loyaltyList.value = state.card;
          } else
            _loadingState.value = LoadingState.empty;
        }
        if (state is ListLoadingOpacityHideState) {
          Navigator.pop(context);
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => ScaffoldAppBarCustom(
        margin: false,
        actions: true,
        leading: true,
        title: "Обратная сторона карты",
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
                          text: "Информация отсутствует",
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
                  builder: (BuildContext context, MyLoyaltyData? _card, _) =>
                      Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: LayoutBuilder(
                                  builder: (BuildContext context,
                                          BoxConstraints constraints) =>
                                      Column(
                                    children:
                                        _listCard(constraints, [_card!, _card]),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.read<DetailCardScreenBloc>().add(
                                          DeleteEvent(id: _card!.id),
                                        ),
                                child: TextWidget(
                                  align: TextAlign.center,
                                  padding: 16,
                                  text: "Удалить карту",
                                  style: StyleTextCustom()
                                      .setStyleByEnum(
                                        context,
                                        StyleTextEnum.neutralText,
                                      )
                                      .copyWith(
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  Widget _singleCard(double maxWidth, int index,
      {required MyLoyaltyData loyalty}) {
    final data = loyalty.data.split("||");
    final String number = data.first;
    final String? type = data.length > 1 ? data.last : null;

    //final data = MyCardDataModel.fromJson(jsonDecode(loyalty.data));

    return index == 0
        ? Container(
            margin: EdgeInsets.only(top: index != 0 ? 16 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              image: DecorationImage(
                image: NetworkImage(
                  baseUrl +
                      (loyalty.customImage == null
                          ? "api/v1/image/content/" + loyalty.blank.image!.name
                          : "api/v1/loyalty-card/custom-image/" +
                              loyalty.customImage!.path),
                  headers: <String, String>{
                    "Authorization": "Bearer " + _token
                  },
                ),
                fit: BoxFit.cover,
              ),
            ),
            height: maxWidth * .62,
          )
        : Container(
            margin: EdgeInsets.only(top: index != 0 ? 16 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              color: StyleColorCustom().setStyleByEnum(
                context,
                StyleColorEnum.secondaryBackground,
              ),
            ),
            height: maxWidth * .62,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextWidget(
                  padding: 0,
                  text: "Данные карты",
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.textButtonCancel),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: BarcodeWidget(
                      barcode: type != null
                          ? Barcode.fromType(BarcodeType.values
                              .where((element) => element
                                  .toString()
                                  .toLowerCase()
                                  .contains(type.toLowerCase()))
                              .first)
                          : Barcode.code128(escapes: true),
                      data: number,
                      width: 163,
                      height: 54,
                    ),
                  ),
                ),
                TextWidget(
                    padding: 0,
                    text: "Номер",
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)
                        .copyWith(color: CustomColors.neutralText)),
                TextWidget(
                  padding: 0,
                  text: number,
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.bodyCard),
                ),
              ],
            ),
          );
  }

  List<Widget> _listCard(
      BoxConstraints constraints, List<MyLoyaltyData> loyaltys) {
    final List<Widget> list = <Widget>[];

    loyaltys.asMap().forEach(
          (key, value) => list.add(
            _singleCard(
              constraints.maxWidth,
              key,
              loyalty: value,
            ),
          ),
        );
    return list;
  }
}
