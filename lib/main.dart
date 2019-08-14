import 'dart:async';

import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/boba_map_bloc.dart';
import 'package:boba_explorer/remote_config_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:launch_review/launch_review.dart';
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

class _BobaMapState extends State<BobaMap> {
  static const _tw101 = const LatLng(25.0339639, 121.5622835);
  GoogleMapController _mapController;
  CameraPosition _cameraPos;
  Set<Marker> _markers;
  ValueNotifier<bool> _isCameraTooFarNotifier = ValueNotifier(true);
  PageController pageController;
  bool isPageSwipedByUser = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.75);
  }

  @override
  Widget build(BuildContext context) {
    //AppBloc appBloc = Provider.of<AppBloc>(context, listen: false);
    BobaMapBloc bobaMapBloc = Provider.of<BobaMapBloc>(context, listen: false);
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          _buildShopFilterBar(),
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: bobaMapBloc?.bobaData,
              builder: (ctx, snapshot) {
                List<DocumentSnapshot> snapshots = snapshot.data;
                _markers = _genMarkers(snapshots);
                return ValueListenableBuilder<bool>(
                  valueListenable: _isCameraTooFarNotifier,
                  builder: (context, isCameraTooFar, child) {
                    return Stack(
                      children: <Widget>[
                        GoogleMap(
                          compassEnabled: false,
                          initialCameraPosition:
                              const CameraPosition(target: _tw101, zoom: 15),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          onMapCreated: (controller) async {
                            _mapController = controller;
                            LatLng _curPosition = await Geolocator()
                                .getCurrentPosition()
                                .then((pos) => pos == null
                                    ? null
                                    : LatLng(pos.latitude, pos.longitude))
                                .catchError((err) {});
                            LatLng pos = _curPosition ?? _tw101;
                            controller
                                .animateCamera(CameraUpdate.newLatLng(pos));
                            bobaMapBloc.seekBoba(
                                lat: pos.latitude, lng: pos.longitude);
                          },
                          markers: isCameraTooFar ? null : _markers,
                          onCameraMove: (pos) {
                            _cameraPos = pos;
                            bool isCameraTooFar = pos.zoom <= 13;
                            _isCameraTooFarNotifier.value = isCameraTooFar;
                          },
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 12,
                          height: 150,
                          child: GestureDetector(
                            onPanDown: (details) => isPageSwipedByUser = true,
                            child: PageView.builder(
                              controller: pageController,
                              onPageChanged: (index) {
                                if (!isPageSwipedByUser) {
                                  return;
                                }
                                GeoPoint position = snapshots[index]
                                    .data["position"]["geopoint"];
                                _moveCamera(position);
                              },
                              itemCount: snapshot.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                return _ShopItem(
                                  shopName: snapshots[index].data["shopName"],
                                  branchName:
                                      snapshots[index].data["branchName"],
                                  city: snapshots[index].data["city"],
                                  district: snapshots[index].data["district"],
                                  address: snapshots[index].data["address"],
                                  phone: snapshots[index].data["phone"],
                                  hue: snapshots[index].data["pinColor"],
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _isCameraTooFarNotifier,
        builder: (context, isCameraTooFar, child) {
          return Visibility(
            visible: !isCameraTooFar,
            child: child,
          );
        },
        child: FloatingActionButton.extended(
          label: Text("Search"),
          icon: Icon(Icons.search),
          onPressed: () {
            if (_cameraPos == null) {
              return;
            }
            LatLng latLng = _cameraPos.target;
            bobaMapBloc.seekBoba(lat: latLng.latitude, lng: latLng.longitude);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  Set<Marker> _genMarkers(List<DocumentSnapshot> snapshots) {
    if (snapshots == null) {
      return null;
    }
    List<Marker> markers = [];
    for (var i = 0; i < snapshots.length; i++) {
      var data = snapshots[i];
      //final shop = data.data["shopName"];
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
          /*infoWindow: InfoWindow(
              title: shop,
              snippet:
                  "Address: ${data.data["city"]}${data.data["district"]}${data.data["address"]}"),*/
          onTap: () async {
            isPageSwipedByUser = false;
            _mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 16));
            //pageController?.jumpToPage(i);
            pageController?.animateToPage(i,
                duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          }));
    }
    /*Iterable<Marker> markers = snapshots.map((data) {
      final shop = data.data["shopName"];
      var hue = data.data["pinColor"];
      hue = double.tryParse(hue.toString()) ?? hue;
      GeoPoint geo = data.data["position"]["geopoint"];
      final pos = LatLng(geo.latitude, geo.longitude);
      return Marker(
          markerId: MarkerId(data.documentID),
          position: pos,
          icon: hue == null
              ? BitmapDescriptor.defaultMarker
              : BitmapDescriptor.defaultMarkerWithHue(hue),
          */ /*infoWindow: InfoWindow(
              title: shop,
              snippet:
                  "Address: ${data.data["city"]}${data.data["district"]}${data.data["address"]}"),*/ /*
          onTap: () async {
            await pageController?.animateToPage(pageController.page.floor(),
                duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            return _mapController
                ?.animateCamera(CameraUpdate.newLatLngZoom(pos, 16));
          });
    });*/
    return Set.from(markers);
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
    Color color = _hue == null
        ? Colors.redAccent
        : HSVColor.fromAHSV(1, _hue.toDouble(), 1, 1).toColor();
    String branchName =
        _branchName.contains("店") ? _branchName : "$_branchName店";
    branchName = branchName.replaceAll("│", "\n");
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomCenter,
                stops: [0.45, 0.45],
                colors: [color, Colors.transparent],
              ),
            ),
            alignment: Alignment.topRight,
            child: Text(_shopName),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topCenter,
                stops: [0.45, 0.45],
                colors: [color, Colors.transparent],
              ),
            ),
            alignment: Alignment.bottomRight,
            child: Text(
              branchName.length > 6 && !branchName.contains("\n")
                  ? "${branchName.substring(0, 6)}\n${branchName.substring(6, branchName.length)}"
                  : branchName,
              textAlign: TextAlign.end,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints:
                          BoxConstraints.tightFor(width: 30, height: 30),
                      child: RaisedButton(
                        padding: EdgeInsets.zero,
                        shape: CircleBorder(),
                        color: Colors.white,
                        elevation: 4,
                        onPressed: () {},
                        child: Icon(Icons.restaurant_menu),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("地址："),
                    Flexible(
                      flex: 55,
                      child: Text("$_city$_district$_address"),
                    ),
                    Spacer(
                      flex: 45,
                    )
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Text("電話："),
                    Text(
                      _phone,
                      style: TextStyle(
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
