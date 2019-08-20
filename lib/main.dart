import 'dart:async';

import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/boba_map_bloc.dart';
import 'package:boba_explorer/remote_config_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:launch_review/launch_review.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      Provider<AppBloc>(
        builder: (_) => AppBloc(),
        dispose: (_, appBloc) => appBloc.dispose(),
        child: MaterialApp(
          home: MyApp(),
        ),
      ),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription _checkVersionSub;
  bool _appVersionChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_appVersionChecked) {
      AppBloc appBloc = Provider.of<AppBloc>(context, listen: false);
      if (_checkVersionSub != null) {
        return;
      }
      _checkVersionSub = appBloc.appVersion.listen((event) {
        if (!event.shouldUpdate) {
          return;
        }
        _appVersionChecked = true;
        showDialog<bool>(
                context: context,
                barrierDismissible: !event.forceUpdate,
                builder: (context) =>
                    _AppUpdateDialog(event.forceUpdate, event.requiredVersion))
            .then((agreeUpdate) {
          if (agreeUpdate == null || !agreeUpdate) {
            return;
          }
          LaunchReview.launch(writeReview: false);
        });
      });
    }
  }

  @override
  void dispose() {
    _checkVersionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<BobaMapBloc>(
      builder: (_) => BobaMapBloc(),
      dispose: (_, bloc) => bloc.dispose(),
      child: BobaMap(),
    );
  }
}

class _AppUpdateDialog extends StatelessWidget {
  final bool _forceUpdate;
  final String _requiredVersion;

  _AppUpdateDialog(this._forceUpdate, this._requiredVersion);

  @override
  Widget build(BuildContext context) {
    List<Widget> options = [
      FlatButton(
          onPressed: () => Navigator.of(context).pop(true), child: Text("Sure"))
    ];
    if (!_forceUpdate) {
      options.insert(
        0,
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text("Later"),
        ),
      );
    }
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        title: Text("Version update"),
        content: Text(
            "A new version $_requiredVersion is available for you. Update the app now :)"),
        actions: options);
  }
}

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
  bool _isPageSwipedByUser = false;
  bool _isTriggeredByMarker = false;

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
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          _buildShopFilterBar(),
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _bobaMapBloc?.bobaData,
              builder: (ctx, snapshot) {
                List<DocumentSnapshot> snapshots = snapshot.data;
                _markers = _genMarkers(snapshots);
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
                      child: _buildShopCards(snapshots),
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
                child: Text(
                  "搜尋飲料店",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
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
          Visibility(
            visible: false, //TODO: Change visibility according to filter status
            replacement: SizedBox(width: 20),
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Icon(Icons.cancel, color: Colors.grey),
              ),
              onTap: () {},
            ),
          ),
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
            onTap: () {
              //TODO: Show shop list dialog for filtering
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
        if (_isTriggeredByMarker) {
          _isTriggeredByMarker = false;
          return;
        }
        if (_isPageSwipedByUser) {
          _isPageSwipedByUser = false;
          return;
        }
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

  Set<Marker> _genMarkers(List<DocumentSnapshot> snapshots) {
    if (snapshots == null) {
      return null;
    }
    List<Marker> markers = [];
    for (var i = 0; i < snapshots.length; i++) {
      var data = snapshots[i];
      var hue = data.data["pinColor"];
      hue = double.tryParse(hue.toString()) ?? hue;
      GeoPoint geo = data.data["position"]["geopoint"];
      final pos = LatLng(geo.latitude, geo.longitude);
      markers.add(Marker(
          markerId: MarkerId(data.documentID),
          position: pos,
          icon: hue == null
              ? BitmapDescriptor.defaultMarker
              : BitmapDescriptor.defaultMarkerWithHue(hue),
          consumeTapEvents: true,
          onTap: () async {
            _isTriggeredByMarker = true;
            _shopInfoPageController?.jumpToPage(i);
          }));
    }
    return Set.from(markers);
  }

  Widget _buildShopCards(List<DocumentSnapshot> shops) {
    return SlideTransition(
      position: _shopCardSlideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onPanDown: (details) => _isPageSwipedByUser = true,
          child: PageView.builder(
            controller: _shopInfoPageController,
            onPageChanged: (index) {
              GeoPoint position = shops[index].data["position"]["geopoint"];
              _moveCamera(position);
            },
            itemCount: shops?.length ?? 0,
            itemBuilder: (context, index) {
              return _ShopItem(
                shopName: shops[index].data["shopName"],
                branchName: shops[index].data["branchName"],
                city: shops[index].data["city"],
                district: shops[index].data["district"],
                address: shops[index].data["address"],
                phone: shops[index].data["phone"],
                hue: shops[index].data["pinColor"],
              );
            },
          ),
        ),
      ),
    );
  }

  void _moveCamera(GeoPoint position) {
    final pos = LatLng(position.latitude, position.longitude);
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
      child: StreamBuilder<List<String>>(
        stream: bloc.filterShopList,
        builder: (context, snapshot) {
          List<String> filteredShops = snapshot.data ?? [];
          bool isSelected = filteredShops.contains(_shop.name);
          return FlatButton(
            color: isSelected ? color.withOpacity(0.5) : Colors.white,
            textColor: isSelected
                ? brightness < 0.1791 ? color : Colors.grey.shade700
                : Colors.grey,
            shape: StadiumBorder(),
            child: Text(_shop.name),
            onPressed: () => bloc.filterShop(_shop.name),
          );
        },
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  final String _shopName;
  final String _branchName;
  final String _city;
  final String _district;
  final String _address;
  final String _phone;
  final int _hue;

  _ShopItem(
      {@required String shopName,
      @required String branchName,
      @required String city,
      @required String district,
      @required String address,
      @required String phone,
      int hue})
      : _shopName = shopName,
        _branchName = branchName,
        _city = city,
        _district = district,
        _address = address,
        _phone = phone,
        _hue = hue;

  @override
  Widget build(BuildContext context) {
    /*Color color = _hue == null
        ? Colors.redAccent
        : HSVColor.fromAHSV(1, _hue.toDouble(), 1, 1).toColor();*/
    String branchName = _branchName.endsWith("店") && !_branchName.endsWith("新店")
        ? _branchName
        : "$_branchName店";
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Text(
                          _shopName,
                          style: Theme.of(context).textTheme.title,
                        ),
                        Spacer(),
                        _buildBranchTag(branchName),
                        SizedBox(width: 4),
                        PopupMenuButton(
                          offset: Offset(0, -20),
                          child: Icon(Icons.more_vert),
                          onSelected: (number) {},
                          itemBuilder: (context) {
                            return <PopupMenuEntry<int>>[
                              PopupMenuItem(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(Icons.share),
                                    SizedBox(width: 8),
                                    Text("分享"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(Icons.report_problem),
                                    SizedBox(width: 8),
                                    Text("回報"),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("地址"),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      "$_city$_district$_address",
                      style: TextStyle(),
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
                      onPressed: () {},
                      icon: Icon(Icons.phone),
                      label: Text("撥號至店家"),
                    ),
                  ),
                  Expanded(
                    child: FlatButton.icon(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: Icon(
                        FontAwesomeIcons.locationArrow,
                        size: 18,
                      ),
                      label: Text("開始導航"),
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
}

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
