import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/SliderModel.dart';
import 'package:wallet_box/app/data/net/models/groups_list_response.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';

import 'subscription_screen_bloc.dart';
import 'subscription_screen_events.dart';
import 'subscription_screen_states.dart';

class SubscriptionScreen extends StatefulWidget {
  SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late UserNotifierProvider _userProvider;

  final ValueNotifier<LoadingState> _loadingState =
      ValueNotifier<LoadingState>(LoadingState.loading);
  final ValueNotifier<List<Group>?> _subscriptionsList =
      ValueNotifier<List<Group>?>(null);
  final CarouselController _controller = CarouselController();
  final ValueNotifier<int> _current = ValueNotifier<int>(0);
  final List<SingleSlide> _list = <SingleSlide>[
    SingleSlide(
      text: "Только сегодня максимальная\nскидка на все!",
      image: AssetsPath.slide_1_png,
    ),
    SingleSlide(
      text: "Только сегодня максимальная\nскидка на все! 2",
      image: AssetsPath.slide_1_png,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    context.read<SubscriptionScreenBloc>().add(
          PageOpenedEvent(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionScreenBloc, SubscriptionScreenState>(
      listener: (context, state) {
        if (state is UpdateSubscriptionsList) {
          List<Subscription> _list = <Subscription>[];
          if (state.groups != null && state.groups!.isNotEmpty) {
            state.groups!.forEach((e) => _list.addAll(e.variants));

            _subscriptionsList.value = state.groups;
            _loadingState.value = LoadingState.loaded;
          } else {
            _loadingState.value = LoadingState.empty;
          }
        }
        if (state is GoToPayScreenState) {
          _linkOpen(state.uri);
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => ScaffoldAppBarCustom(
        leading: true,
        minimum: EdgeInsets.zero,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  height: 45,
                  child: ConstContext.lightMode(context)
                      ? Image.asset(logoLight)
                      : Image.asset(logoDark),
                ),
                _sliderWidget(context),
                _subscriptionsListWidget(),
              ],
            ),
          ),
        ),
      );

  Widget _sliderWidget(BuildContext context) => Column(children: [
        CarouselSlider(
          items: _list
              .map(
                (e) => Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 24),
                  child: ContainerCustom(
                    width: true,
                    margin: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(e.image),
                        TextWidget(
                          text: e.text,
                          style: StyleTextCustom()
                              .setStyleByEnum(context, StyleTextEnum.bodyCard),
                          align: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
          carouselController: _controller,
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 1.45,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) => _current.value = index,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _current,
          builder: (BuildContext context, int _index, _) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _list.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: StyleColorCustom().setStyleByEnum(
                      context,
                      _index == entry.key
                          ? StyleColorEnum.colorIcon
                          : StyleColorEnum.secondaryBackground,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ]);

  Widget _subscriptionsListWidget() => ValueListenableBuilder(
        valueListenable: _loadingState,
        builder: (BuildContext context, LoadingState _state, _) =>
            ValueListenableBuilder(
          valueListenable: _subscriptionsList,
          builder: (BuildContext context, List<Group>? _items, _) {
            late Widget _child;
            switch (_state) {
              case LoadingState.loading:
                _child = Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Center(child: CircularProgressIndicator()),
                );
                break;
              case LoadingState.empty:
                _child = Center(
                  child: TextWidget(
                    text: "На данный момент нет доступных подписок",
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard),
                    align: TextAlign.center,
                  ),
                );
                break;
              case LoadingState.loaded:
                _child = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        _singleSubscriptionCard(
                            item: Group(
                                id: "custom", name: "Lite", variants: [])),
                        ..._items!
                            .map((e) => _singleSubscriptionCard(item: e))
                            .toList(),
                      ],
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    TextWidget(
                        align: TextAlign.center,
                        padding: 0,
                        text: textString_58,
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.bodyCard)),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                );
                break;
            }

            return _child;
          },
        ),
      );

  void _linkOpen(String url) async {
    if (await canLaunch(url))
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        universalLinksOnly: false,
      );
    else
      throw "Could not launch $url";
  }

  Widget _singleSubscriptionCard({required Group item}) {
    item.variants.sort((a, b) => a.expiration.compareTo(b.expiration));

    return ButtonWhite(
      padding: 5,
      text: "",
      onPressed: () => (item.variants.isNotEmpty)
          ? _linkOpen(baseUrlDomain + "sub/" + item.id)
          : {},
      size: true,
      customText: RichText(
        text: TextSpan(
          text: item.name + " ",
          style: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.textButtonCancel)
              .copyWith(color: CustomColors.lightSecondaryText),
          children: (item.variants.isNotEmpty)
              ? [
                  TextSpan(
                    text: _price(item.variants.first),
                  ),
                  TextSpan(
                    text: item.variants.first.price != 0
                        ? " "
                        : "",
                  ),
                  TextSpan(
                    text: item.variants.first.price != 0
                        ? item.variants.first.price.round().toString()
                        : "",
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.textButtonCancel)
                        .copyWith(
                          color: item.variants.first.price != 0
                              ? CustomColors.darkButtonBackground
                              : CustomColors.lightSecondaryText,
                          decoration: TextDecoration.lineThrough,
                        ),
                  ),
                  TextSpan(
                      text:
                          " " + item.variants.first.newPrice.round().toString(),
                      style: StyleTextCustom()
                          .setStyleByEnum(
                              context, StyleTextEnum.textButtonCancel)
                          .copyWith(
                            color: item.variants.first.price != 0
                                ? CustomColors.pink
                                : CustomColors.lightSecondaryText,
                          )),
                  const TextSpan(text: ' руб.'),
                ]
              : [
                  TextSpan(text: ' подписка активирована'),
                ],
        ),
      ),
    );
  }

  String declensionsWords(int number, List<String> words) {
    return words[(number % 100 > 4 && number % 100 < 20)
        ? 2
        : [2, 0, 1, 1, 1, 2][(number % 10 < 5) ? number % 10 : 5]];
  }

  String _price(Subscription item) {
    if (item.expiration % 7 == 0) {
      return (item.expiration / 7).round().toString() +
          " ${declensionsWords((item.expiration / 7).round(), [
                "неделя",
                "недели",
                "недель"
              ])}";
    } else if (item.expiration % 30 == 0) {
      return (item.expiration / 30).round().toString() +
          " ${declensionsWords((item.expiration / 30).round(), [
                "месяц",
                "месяца",
                "месяцев"
              ])}";
    } else {
      return item.expiration.toString() +
          " ${declensionsWords((item.expiration).round(), [
                "день",
                "дня",
                "дней"
              ])}";
    }
  }
}
