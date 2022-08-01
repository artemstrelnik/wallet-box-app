import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/src/provider.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/net/models/currenci_model.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/settings_screens/currencies_screens/currencies_screens_bloc.dart';
import 'package:wallet_box/app/screens/settings_screens/setting_main/setting_screen_states.dart';

import 'currencies_screens_events.dart';
import 'currencies_screens_states.dart';

class CurrenciesScreen extends StatefulWidget {
  const CurrenciesScreen({
    Key? key,
    required this.list,
    required this.selected,
  }) : super(key: key);

  final List<Currency> list;
  final Currency selected;
  @override
  _CurrenciesScreenState createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  late UserNotifierProvider _userProvider;
  late ValueNotifier<Currency> _currencyNotifier;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currencyNotifier = ValueNotifier<Currency>(widget.selected);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    return BlocListener<CurrenciesScreenBloc, CurrenciesScreenState>(
      listener: (context, state) {
        if (state is UpdateUserInfo) {
          _userProvider.setUser = state.user;
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => ScaffoldAppBarCustom(
        header: textString_42,
        leading: true,
        body: ValueListenableBuilder(
          valueListenable: _currencyNotifier,
          builder: (BuildContext context, Currency? _item, _) => ListView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            children: widget.list
                .map((item) => _singleCurrency(item, _item == item))
                .toList(),
          ),
        ),
      );

  Widget _singleCurrency(Currency item, bool active) => GestureDetector(
        onTap: () {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            _currencyNotifier.value = item;
            context.read<CurrenciesScreenBloc>().add(
                  UserUpdateInfoEvent(
                    data: <String, dynamic>{
                      "walletType": item.walletSystemName,
                    },
                    user: _userProvider.user!,
                  ),
                );
          });
        },
        child: ContainerCustom(
          child: Row(
            children: [
              Expanded(
                child: TextWidget(
                    padding: 0,
                    text: item.walletDisplayName,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                child: TextWidget(
                    padding: 0,
                    text: item.walletSystemName,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)),
              ),
              active
                  ? const Padding(
                      padding: EdgeInsets.only(right: 8.0, top: 2.0),
                      child: Icon(
                        Icons.check,
                        color: CustomColors.pink,
                      ),
                    )
                  : Container(
                      height: 26,
                    ),
            ],
          ),
        ),
      );
}
