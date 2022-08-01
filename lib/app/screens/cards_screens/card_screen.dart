import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/my_loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/add_card_screens/add_card_screen.dart';
import 'package:wallet_box/app/screens/add_card_screens/add_card_screen_bloc.dart';
import 'package:wallet_box/app/screens/detail_card_screen/detail_card_screen.dart';
import 'package:wallet_box/app/screens/detail_card_screen/detail_card_screen_bloc.dart';

import 'card_screen_bloc.dart';
import 'card_screen_events.dart';
import 'card_screen_states.dart';

class CardScreen extends StatefulWidget {
  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  late UserNotifierProvider _userProvider;
  final ValueNotifier<LoadingState> _loadingState =
      ValueNotifier<LoadingState>(LoadingState.loading);

  final ValueNotifier<List<MyLoyaltyData>> _loyaltyList =
      ValueNotifier<List<MyLoyaltyData>>(<MyLoyaltyData>[]);

  late String _token;

  @override
  void initState() {
    super.initState();
    context.read<CardScreenBloc>().add(
          PageOpenedEvent(),
        );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    return BlocListener<CardScreenBloc, CardScreenState>(
      listener: (context, state) {
        if (state is UpdateMyLoyalty) {
          if (state.list != null && state.list!.isNotEmpty) {
            _token = state.token;
            _loyaltyList.value = state.list!;
            _loadingState.value = LoadingState.loaded;
          } else
            _loadingState.value = LoadingState.empty;
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => ScaffoldAppBarCustom(
        margin: false,
        actions: true,
        leading: true,
        title: textString_67,
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
                          text: "Вы еще не добавляли карт",
                          style: StyleTextCustom()
                              .setStyleByEnum(context, StyleTextEnum.bodyCard),
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                    _addButton(),
                  ],
                );
              case LoadingState.loaded:
                return ValueListenableBuilder(
                  valueListenable: _loyaltyList,
                  builder:
                      (BuildContext context, List<MyLoyaltyData> _list, _) =>
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
                                    children: _listCard(constraints, _list),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _addButton(),
                    ],
                  ),
                );
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  Widget _singleCard(double maxWidth, double index,
          {bool islast = false, required MyLoyaltyData loyalty}) =>
      GestureDetector(
        onTap: () async {
          final bool? returnBack = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => DetailCardScreenBloc(cardId: loyalty.id),
                child: DetailCardScreen(),
              ),
            ),
          );
          context.read<CardScreenBloc>().add(
                PageOpenedEvent(),
              );
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          height: islast ? maxWidth * .62 : maxWidth * .2 - 14,
          child: Stack(
            children: [
              Positioned(
                height: islast ? maxWidth * .62 : maxWidth * .2,
                top: -14,
                width: maxWidth,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: islast
                        ? BorderRadius.all(Radius.circular(14))
                        : BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                    image: DecorationImage(
                      image: NetworkImage(
                        baseUrl +
                            (loyalty.customImage == null
                                ? "api/v1/image/content/" +
                                    loyalty.blank.image!.name
                                : "api/v1/loyalty-card/custom-image/" +
                                    loyalty.customImage!.path),
                        headers: <String, String>{
                          "Authorization": "Bearer " + _token
                        },
                      ),
                      fit: BoxFit.cover,
                      alignment:
                          !islast ? Alignment.topCenter : Alignment.center,
                    ),
                  ),
                  height: islast ? maxWidth * .62 : maxWidth * .2,
                ),
              ),
            ],
          ),
        ),
      );

  List<Widget> _listCard(
      BoxConstraints constraints, List<MyLoyaltyData> loyalty) {
    final List<Widget> list = <Widget>[];

    loyalty.asMap().forEach((key, value) => list.add(_singleCard(
        constraints.maxWidth, key.toDouble(),
        islast: loyalty.length == key + 1, loyalty: value)));
    return list;
  }

  Widget _addButton() => ContainerCustom(
        margin: true,
        width: true,
        child: SizedBox(
          width: 200,
          child: ButtonPink(
            widthCustom: 200,
            text: textString_27,
            onPressed: () async {
              final bool? returnBack = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) => AddCardScreenBloc(),
                    child: AddCardScreen(),
                  ),
                ),
              );
              context.read<CardScreenBloc>().add(
                    PageOpenedEvent(),
                  );
            },
          ),
        ),
      );
}
