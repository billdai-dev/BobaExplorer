import 'dart:async';
import 'dart:io';

import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop.dart';
import 'package:boba_explorer/remote_config_model.dart';
import 'package:boba_explorer/ui/boba_map_page/boba_map_bloc.dart';
import 'package:boba_explorer/ui/boba_map_page/shop_filter_dialog.dart';
import 'package:boba_explorer/ui/search_boba_page/search_boba_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class BobaMap extends StatefulWidget {
  BobaMap({Key key}) : super(key: key);

  @override
  _BobaMapState createState() => _BobaMapState();
}

class _BobaMapState extends State<BobaMap> with SingleTickerProviderStateMixin {
  static const _tw101 = const LatLng(25.0339639, 121.5622835);
  BobaMapBloc _bobaMapBloc;
  GoogleMapController _mapController;
  CameraPosition _cameraPos;
  Set<Marker> _markers;
  ValueNotifier<bool> _isCameraTooFarNotifier = ValueNotifier(true);
  ValueNotifier<bool> _searchBtnVisibilityNotifier = ValueNotifier(false);
  PageController _shopInfoPageController;
  bool _shouldBlockNextMove = false;

  Completer<BitmapDescriptor> _markerIconCompleter;
  BitmapDescriptor _markerIcon;

  AnimationController _animController;
  Animation<double> _fadeAnim;
  Animation<Offset> _shopCardSlideAnim;

  @override
  void initState() {
    super.initState();
    _bobaMapBloc = Provider.of<BobaMapBloc>(context, listen: false);
    _shopInfoPageController = PageController(viewportFraction: 0.85);

    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnim = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.fastOutSlowIn));
    _shopCardSlideAnim = Tween(begin: Offset(0, 0), end: Offset(0, 1)).animate(
        CurvedAnimation(parent: _animController, curve: Curves.fastOutSlowIn));
    _markerIconCompleter = Completer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BitmapDescriptor.fromAssetImage(
              createLocalImageConfiguration(context, size: Size(96, 164)),
              "assets/images/bubble_tea.png")
          .then((icon) => _markerIconCompleter.complete(icon));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _shopInfoPageController?.dispose();
    _animController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          _buildShopFilterBar(),
          Expanded(
            child: StreamBuilder<List<TeaShop>>(
              stream: _bobaMapBloc?.teaShops,
              builder: (ctx, snapshot) {
                Future(() {
                  if (snapshot.hasData) {
                    _shouldBlockNextMove = true;
                    _shopInfoPageController?.jumpToPage(0);
                  }
                });

                List<TeaShop> teaShops = snapshot.data;
                _markers = _genMarkers(teaShops);
                return Stack(
                  children: <Widget>[
                    _buildMap(_markers),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 15,
                      height: 50,
                      child: FractionallySizedBox(
                        widthFactor: 0.6,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: _buildSearchButton(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      height: 150,
                      child: _buildShopCards(teaShops),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Container(
        width: double.infinity,
        height: 50,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          child: Row(
            children: <Widget>[
              SizedBox(width: 12),
              CircleAvatar(radius: 15, child: Text("戴")),
              //TODO: Add 3rd party login
              SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    String query = await showSearch<String>(
                      context: context,
                      delegate: SearchBobaDelegate(),
                    );
                    if (query == null || query.isEmpty) {
                      return;
                    }
                    _bobaMapBloc?.filter(shops: {query});
                  },
                  child: Text(
                    "搜尋飲料店",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.favorite, color: Colors.redAccent),
                onPressed: () {
                  //TODO: Go to favorite page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopFilterBar() {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          StreamBuilder<Set<String>>(
              stream: _bobaMapBloc.filterList,
              builder: (context, snapshot) {
                bool isFiltering = snapshot.data?.isNotEmpty == true;
                return Visibility(
                  visible: isFiltering,
                  replacement: SizedBox(width: 20),
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 4),
                      child: Icon(Icons.cancel, color: Colors.grey),
                    ),
                    onTap: () => _bobaMapBloc?.filter(shops: {}),
                  ),
                );
              }),
          Expanded(
            child: Consumer<AppBloc>(
              builder: (_, appBloc, child) {
                return StreamBuilder<List<Shop>>(
                  stream: appBloc.supportedShops,
                  builder: (context, snapshot) {
                    List<Shop> shops = snapshot.data ?? [];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: shops.length,
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      itemBuilder: (context, index) {
                        return ShopFilterButton(shops[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 8),
              child: Icon(Icons.filter_list),
            ),
            onTap: () async {
              var filteredShops = await _bobaMapBloc.filterList.first;
              var newFilteredShops = await showDialog(
                context: context,
                builder: (context) => ShopFilterDialog(filteredShops),
              );
              if (newFilteredShops == null) {
                return;
              }
              _bobaMapBloc.filter(shops: newFilteredShops);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return ValueListenableBuilder(
      valueListenable: _searchBtnVisibilityNotifier,
      builder: (context, isVisible, child) {
        return Visibility(
          visible: isVisible,
          child: ValueListenableBuilder(
            valueListenable: _isCameraTooFarNotifier,
            builder: (context, isCameraTooFar, child) {
              var onTap;
              if (!isCameraTooFar) {
                onTap = () {
                  if (_cameraPos == null) {
                    return;
                  }
                  _searchBtnVisibilityNotifier.value = false;
                  LatLng latLng = _cameraPos.target;
                  _bobaMapBloc?.seekBoba(
                      lat: latLng.latitude, lng: latLng.longitude);
                };
              }
              return FadeTransition(
                opacity: _fadeAnim,
                child: RaisedButton.icon(
                  elevation: 8,
                  color: Colors.white,
                  disabledColor: Colors.blueGrey,
                  disabledTextColor: Colors.white,
                  textColor: Colors.black54,
                  shape: StadiumBorder(),
                  onPressed: onTap,
                  icon: Icon(
                    isCameraTooFar ? Icons.error : Icons.search,
                    color: isCameraTooFar ? Colors.white : Colors.black54,
                  ),
                  label: Text(isCameraTooFar ? "請放大後再進行搜尋哦" : "搜尋此區域"),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMap(Set<Marker> markers) {
    return GoogleMap(
      compassEnabled: false,
      initialCameraPosition: const CameraPosition(target: _tw101, zoom: 15),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      onMapCreated: (controller) async {
        _mapController = controller;
        _markerIcon = await _markerIconCompleter.future;
        LatLng _curPosition = await Geolocator()
            .getCurrentPosition()
            .then((pos) =>
                pos == null ? null : LatLng(pos.latitude, pos.longitude))
            .catchError((err) {});
        LatLng pos = _curPosition ?? _tw101;
        controller.animateCamera(CameraUpdate.newLatLng(pos));
        _bobaMapBloc.seekBoba(lat: pos.latitude, lng: pos.longitude);
      },
      markers: markers,
      onCameraMoveStarted: () {
        if (_shouldBlockNextMove) {
          _shouldBlockNextMove = false;
          return;
        }
        /*if (_isTriggeredByMarker) {
          _isTriggeredByMarker = false;
          return;
        }
        if (_isPageSwipedByUser) {
          _isPageSwipedByUser = false;
          return;
        }*/
        if (_animController.status != AnimationStatus.completed) {
          _animController.forward();
        }
      },
      onCameraMove: (pos) {
        _cameraPos = pos;
        bool isCameraTooFar = pos.zoom <= 13;
        _isCameraTooFarNotifier.value = isCameraTooFar;
      },
      onCameraIdle: () {
        _searchBtnVisibilityNotifier.value = true;
        if (_animController.status != AnimationStatus.dismissed) {
          _animController.reverse();
        }
      },
    );
  }

  Set<Marker> _genMarkers(List<TeaShop> shops) {
    if (shops == null || _markerIcon == null) {
      return null;
    }
    List<Marker> markers = [];
    for (var i = 0; i < shops.length; i++) {
      var shop = shops[i];
      /*var hue = shop.pinColor;
      hue = double.tryParse(hue.toString()) ?? hue;*/
      double lat = shop.position.latitude;
      double lng = shop.position.longitude;

      final pos = LatLng(lat, lng);
      markers.add(Marker(
          markerId: MarkerId('$lat,$lng'),
          position: pos,
          icon: _markerIcon,
          consumeTapEvents: true,
          onTap: () {
            _shouldBlockNextMove = true;
            _shopInfoPageController?.jumpToPage(i);
          }));
    }
    return Set.from(markers);
  }

  Widget _buildShopCards(List<TeaShop> shops) {
    return SlideTransition(
      position: _shopCardSlideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onPanDown: (details) => _shouldBlockNextMove = true,
          child: PageView.builder(
            controller: _shopInfoPageController,
            onPageChanged: (index) {
              TeaShop shop = shops[index];
              //GeoPoint position = shops[index].data["position"]["geopoint"];
              _moveCamera(shop.position.latitude, shop.position.longitude);
            },
            itemCount: shops?.length ?? 0,
            itemBuilder: (context, index) {
              TeaShop shop = shops[index];
              return _ShopItem(shop);
            },
          ),
        ),
      ),
    );
  }

  void _moveCamera(double lat, double lng) {
    final pos = LatLng(lat, lng);
    _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
  }
}

class ShopFilterButton extends StatelessWidget {
  final Shop _shop;

  ShopFilterButton(this._shop, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BobaMapBloc bloc = Provider.of<BobaMapBloc>(context, listen: false);
    Color color = Color.fromARGB(
        _shop.color.a, _shop.color.r, _shop.color.g, _shop.color.b);
    double brightness = color.computeLuminance();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: StreamBuilder<Set<String>>(
        stream: bloc.filterList,
        builder: (context, snapshot) {
          Set<String> filteredShops = snapshot.data ?? {};
          bool isSelected = filteredShops.contains(_shop.name);
          return FlatButton(
            color: isSelected ? color.withOpacity(0.5) : Colors.white,
            textColor: isSelected
                ? brightness < 0.1791 ? color : Colors.grey.shade700
                : Colors.grey,
            shape: StadiumBorder(),
            child: Text(_shop.name),
            onPressed: () => bloc.filter(shop: _shop.name),
          );
        },
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  final TeaShop _shop;

  _ShopItem(this._shop);

  @override
  Widget build(BuildContext context) {
    /*Color color = _hue == null
        ? Colors.redAccent
        : HSVColor.fromAHSV(1, _hue.toDouble(), 1, 1).toColor();*/
    String shopName = _shop.shopName;
    String branchName = _shop.branchName;
    branchName = branchName.endsWith("店") && !branchName.endsWith("新店")
        ? branchName
        : "$branchName店";
    String city = _shop.city;
    String district = _shop.district;
    String address = _shop.address;
    String phone = _shop.phone;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 52, 146, 210),
              Color.fromARGB(255, 242, 252, 254),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Text(
                          shopName,
                          style: Theme.of(context).textTheme.title,
                        ),
                        Spacer(),
                        _buildBranchTag(branchName),
                        SizedBox(width: 4),
                        PopupMenuButton<_ShopOverflowOption>(
                          offset: Offset(0, -20),
                          child: Icon(Icons.more_vert),
                          onSelected: (option) => _handleOverflowAction(
                            option,
                            shopName: shopName,
                            branchName: branchName,
                            address: "$city$district$address",
                          ),
                          itemBuilder: (context) {
                            return <PopupMenuEntry<_ShopOverflowOption>>[
                              PopupMenuItem(
                                value: _ShopOverflowOption.share,
                                child: buildPopupMenuButton(
                                  "分享",
                                  icon: Icons.share,
                                ),
                              ),
                              PopupMenuItem(
                                value: _ShopOverflowOption.report,
                                child: buildPopupMenuButton(
                                  "回報",
                                  icon: Icons.report_problem,
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text("地址"),
                    SizedBox(height: 2),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Text(
                            "$city$district$address",
                            style: TextStyle(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            Container(
              height: 45,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: FlatButton.icon(
                      padding: EdgeInsets.zero,
                      onPressed: () => _launchDial(phone),
                      icon: Icon(Icons.phone),
                      label: Text("撥號至店家"),
                    ),
                  ),
                  Expanded(
                    child: FlatButton.icon(
                      padding: EdgeInsets.zero,
                      onPressed: () => _launchMaps("$city$district$address"),
                      icon: Icon(
                        FontAwesomeIcons.locationArrow,
                        size: 18,
                      ),
                      label: Text("在地圖上查看"),
                    ),
                  ),
                  Container(
                    width: 54,
                    child: CustomPaint(
                      painter: _FavoriteStampCustomPainter(),
                      child: Container(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.favorite_border,
                            color: Colors.redAccent.shade200,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchTag(String branchName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        color: Color.fromARGB(255, 28, 210, 183),
      ),
      child: Text(branchName),
    );
  }

  Future<void> _launchDial(String phoneNumber) async {
    String dialUri = "tel:$phoneNumber";
    if (await canLaunch(dialUri)) {
      await launch(dialUri);
    }
  }

  Future<void> _launchMaps(String address) async {
    String googleMapUrl =
        "https://www.google.com/maps/search/?api=1&query=$address";
    googleMapUrl = Uri.encodeFull(googleMapUrl);
    if (Platform.isIOS) {
      if (!await canLaunch("googlemaps://")) {
        var iosMapUrl = "http://maps.apple.com/?q=$address";
        iosMapUrl = Uri.encodeFull(iosMapUrl);
        await launch(iosMapUrl);
        return;
      }
    }
    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    }
  }

  Widget buildPopupMenuButton(String text, {IconData icon}) {
    return Column(
      children: <Widget>[
        if (icon != null)
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon),
                SizedBox(width: 8),
                Text(text),
              ],
            ),
          )
        else
          Flexible(child: Text(text)),
        Divider(height: 12),
      ],
    );
  }

  Future<void> _handleOverflowAction(_ShopOverflowOption option,
      {String shopName = "",
      String branchName = "",
      String address = ""}) async {
    if (option == _ShopOverflowOption.share) {
      String googleMapUrl =
          "https://www.google.com/maps/search/?api=1&query=$address";
      googleMapUrl = Uri.encodeFull(googleMapUrl);
      await Share.share("$shopName, $branchName\n$googleMapUrl");
    } else if (option == _ShopOverflowOption.report) {}
  }
}

enum _ShopOverflowOption { share, report }

class _FavoriteStampCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.grey;
    paint.strokeWidth = 1.2;
    paint.style = PaintingStyle.stroke;

    var dash = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height);
    canvas.drawPath(
        dashPath(dash, dashArray: CircularIntervalList([4, 6])), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
