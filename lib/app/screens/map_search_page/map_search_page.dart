import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class SearchExample extends StatefulWidget {
  SearchExample({this.lon, this.lat});

  final double? lon;
  final double? lat;

  @override
  _SearchExampleState createState() => _SearchExampleState();
}

class _SearchExampleState extends State<SearchExample> {
  final TextEditingController queryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<List<SearchItem>?> _searchResult =
      ValueNotifier<List<SearchItem>?>(null);

  late SearchItem _searchItem;

  final ValueNotifier<bool> _addressIsSelected = ValueNotifier<bool>(false);
  late Point? _point;
  late YandexMapController _yandexMapController;

  List<MapObject> mapObjects = [];
  bool _isFirstOpen = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldAppBarCustom(
      minimum: EdgeInsets.zero,
      title: "Местоположение",
      leading: true,
      body: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: YandexMap(
              // onMapLongTap: (point) {
              //   _searchByPoint(point);
              // },
              // onMapTap: (point) {
              //   _searchByPoint(point);
              // },
              rotateGesturesEnabled: false,
              mapObjects: mapObjects,
              onMapCreated: (YandexMapController yandexMapController) async {
                _yandexMapController = yandexMapController;

                if (_isFirstOpen) {
                  if (widget.lon != null && widget.lat != null) {
                    _point =
                        Point(latitude: widget.lat!, longitude: widget.lon!);
                    _searchByPoint(_point!);
                  } else {
                    _point = null;
                  }
                  _isFirstOpen = false;
                }

                if (_point != null) {
                  await yandexMapController.moveCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: _point!, zoom: 18),
                    ),
                  );
                }
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Form(
              key: _formKey,
              child: Container(
                color: StyleColorCustom()
                    .setStyleByEnum(context, StyleColorEnum.primaryBackground),
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 3),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: TextFieldWidget(
                            singleLines: true,
                            paddingTop: EdgeInsets.zero,
                            textAlign: TextAlign.start,
                            autofocus: true,
                            textInputType: TextInputType.streetAddress,
                            style: StyleTextCustom().setStyleByEnum(
                                context, StyleTextEnum.neutralText),
                            labelText: "Введите адрес",
                            fillColor: StyleColorCustom().setStyleByEnum(
                                context, StyleColorEnum.secondaryBackground),
                            validation: (String? value) {
                              if (value == null || value.length < 3) {
                                return 'Пожалуйста введите адрес';
                              }
                              return null;
                            },
                            controller: queryController,
                            isSearch: true,
                          ),
                        ),
                        const SizedBox(width: 18, height: 1),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _search,
                          child: SizedBox(
                            height: 47,
                            width: 47,
                            child: Center(
                              child: SvgPicture.asset(AssetsPath.search),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ValueListenableBuilder(
                      valueListenable: _searchResult,
                      builder: (BuildContext context, List<SearchItem>? _items,
                              _) =>
                          _items == null
                              ? Container()
                              : Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 250.0,
                                  ),
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: _items
                                          .map(
                                            (e) => GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onTap: () async {
                                                queryController.text = e
                                                    .toponymMetadata!
                                                    .address
                                                    .formattedAddress;
                                                _searchResult.value = [];
                                                _addressIsSelected.value = true;
                                                _searchItem = e;

                                                setState(() {
                                                  mapObjects = [
                                                    Placemark(
                                                        mapId: MapObjectId(
                                                            'normal_icon_placemark'),
                                                        point: e.geometry.first
                                                            .point!,
                                                        opacity: 0.7,
                                                        direction: 0,
                                                        icon: PlacemarkIcon.single(
                                                            PlacemarkIconStyle(
                                                                image: BitmapDescriptor
                                                                    .fromAssetImage(
                                                                        'lib/app/assets/icons/place.png'),
                                                                rotationType:
                                                                    RotationType
                                                                        .rotate)))
                                                  ];
                                                });
                                                await _yandexMapController
                                                    .moveCamera(
                                                  CameraUpdate
                                                      .newCameraPosition(
                                                    CameraPosition(
                                                      target: e.geometry.first
                                                          .point!,
                                                      zoom: 18,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                child: TextWidget(
                                                  padding: 0,
                                                  text: e.toponymMetadata!
                                                      .address.formattedAddress,
                                                  style: StyleTextCustom()
                                                      .setStyleByEnum(
                                                          context,
                                                          StyleTextEnum
                                                              .bodyCard),
                                                  align: TextAlign.start,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: _addressIsSelected,
                builder: (BuildContext context, bool _state, _) => Opacity(
                  opacity: _state ? 1 : .3,
                  child: IgnorePointer(
                    ignoring: _state ? false : true,
                    child: ButtonPink(
                      text: "Сохранить",
                      onPressed: () {
                        Navigator.pop(context, _searchItem);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: () async {
                final position = await getLocation();
                _point = Point(
                    latitude: position!.latitude,
                    longitude: position.longitude);

                setState(() {
                  mapObjects = [
                    Placemark(
                        mapId: MapObjectId('normal_icon_placemark'),
                        point: _point!,
                        // onTap: (Placemark self,
                        //         Point point) =>
                        //     print(
                        //         'Tapped me at $point'),
                        opacity: 0.7,
                        //direction: 90,
                        //isDraggable: true,
                        // onDragStart: (_) =>
                        //     print('Drag start'),
                        // onDrag: (_, Point point) =>
                        //     print(
                        //         'Drag at point $point'),
                        // onDragEnd: (_) =>
                        //     print('Drag end'),
                        icon: PlacemarkIcon.single(PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage(
                                'lib/app/assets/icons/place.png'),
                            rotationType: RotationType.rotate)))
                  ];
                });
                _searchByPoint(_point!);
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: const EdgeInsets.all(3),
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: SvgPicture.asset(
                  AssetsPath.target,
                  color: CustomColors.pink,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<Position?> getLocation() async {
    LocationPermission permission;
    Position position;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    try {
      position =
          await Geolocator.getCurrentPosition(timeLimit: Duration(seconds: 15));
      return position;
    } catch (e) {
      return null;
    }
  }

  List<SearchItem>? searchByText(String query) {
    _search(query: query);
    return _searchResult.value;
  }

  void _search({String? query}) async {
    final String _query = query ?? queryController.text;
    final SearchResultWithSession resultWithSession = await _resultList(_query);
    final SearchSessionResult t = await resultWithSession.result;

    _searchResult.value = t.items;
  }

  SearchResultWithSession _resultList(String query) =>
      YandexSearch.searchByText(
        searchText: query,
        geometry:  Geometry.fromBoundingBox(BoundingBox(
          southWest:
              Point(latitude: 55.76996383933034, longitude: 37.57483142322235),
          northEast: Point(
              latitude: 55.785322774728414, longitude: 37.590924677311705),
        )),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: false,
        ),
      );

  void _searchByPoint(Point point) async {
    final SearchResultWithSession resultWithSession =
        YandexSearch.searchByPoint(
      point: point,
      zoom: 18,
      searchOptions: const SearchOptions(
        searchType: SearchType.geo,
        geometry: false,
      ),
    );
    final SearchSessionResult t = await resultWithSession.result;
    _searchItem = t.items!.first;
    queryController.text =
        _searchItem.toponymMetadata!.address.formattedAddress;
    _addressIsSelected.value = true;

    _searchResult.value = [];
    _addressIsSelected.value = true;
    _searchItem = _searchItem;
    setState(() {
      mapObjects = [
        Placemark(
            mapId: MapObjectId('normal_icon_placemark'),
            point: _searchItem.geometry.first.point!,
            opacity: 0.7,
            direction: 0,
            icon: PlacemarkIcon.single(PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                    'lib/app/assets/icons/place.png'),
                rotationType: RotationType.rotate)))
      ];
    });
    await _yandexMapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _searchItem.geometry.first.point!,
          zoom: 18,
        ),
      ),
    );
  }
}
