import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/boba_map_bloc.dart';
import 'package:boba_explorer/remote_config_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:launch_review/launch_review.dart';

void main() => runApp(BlocProviderList(
      listBloc: [Bloc(AppBloc())],
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MyApp(),
      ),
    ));

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
      AppBloc appBloc = BlocProviderList.of<AppBloc>(context);
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
    return BlocProvider(
      bloc: BobaMapBloc(),
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
  bool _isCameraTooFar = false;

  @override
  Widget build(BuildContext context) {
    BobaMapBloc bobaMapBloc = BlocProvider.of<BobaMapBloc>(context);
    AppBloc appBloc = BlocProviderList.of<AppBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('BobaExplorer'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 50,
            color: Colors.white,
            child: StreamBuilder<List<Shop>>(
              stream: appBloc.supportedShops,
              builder: (context, snapshot) {
                List<Shop> shops = snapshot.data ?? [];
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: shops.length,
                  padding: const EdgeInsets.all(8),
                  /*children: shops == null || shops.isEmpty
                        ? []
                        : shops.map((shop) => ShopFilterButton(shop)).toList(),*/
                  itemBuilder: (context, index) => ShopFilterButton(
                        shops[index],
                        key: ValueKey(index),
                      ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
                stream: bobaMapBloc?.bobaData,
                builder: (ctx, snapshot) {
                  _markers = _genMarkers(snapshot.data);
                  return GoogleMap(
                    compassEnabled: false,
                    initialCameraPosition:
                        const CameraPosition(target: _tw101, zoom: 15),
                    onMapCreated: (controller) async {
                      _mapController = controller;
                      LatLng _curPosition = await Geolocator()
                          .getCurrentPosition()
                          .then((pos) => pos == null
                              ? null
                              : LatLng(pos.latitude, pos.longitude))
                          .catchError((err) {});
                      LatLng pos = _curPosition ?? _tw101;
                      controller.animateCamera(CameraUpdate.newLatLng(pos));
                      bobaMapBloc.seekBoba(
                          lat: pos.latitude, lng: pos.longitude);
                    },
                    markers:
                        _isCameraTooFar || !snapshot.hasData ? null : _markers,
                    onCameraMove: (pos) {
                      _cameraPos = pos;
                      bool tooFar = pos.zoom <= 13;
                      if (tooFar == _isCameraTooFar) {
                        return;
                      }
                      setState(() => _isCameraTooFar = !_isCameraTooFar);
                    },
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text("Search"),
          icon: Icon(Icons.search),
          onPressed: () {
            if (_cameraPos == null) {
              return;
            }
            LatLng latLng = _cameraPos.target;
            bobaMapBloc.seekBoba(lat: latLng.latitude, lng: latLng.longitude);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Set<Marker> _genMarkers(List<DocumentSnapshot> snapshots) {
    if (snapshots == null) {
      return null;
    }
    Iterable<Marker> markers = snapshots.map((data) {
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
          infoWindow: InfoWindow(
              title: shop,
              snippet:
                  "Address: ${data.data["city"]}${data.data["district"]}${data.data["address"]}"),
          onTap: () => _mapController
              ?.animateCamera(CameraUpdate.newLatLngZoom(pos, 16)));
    });
    return Set.from(markers);
  }
}

class ShopFilterButton extends StatefulWidget {
  final Shop _shop;

  ShopFilterButton(this._shop, {Key key}) : super(key: key);

  @override
  _ShopFilterButtonState createState() => _ShopFilterButtonState();
}

class _ShopFilterButtonState extends State<ShopFilterButton> {
  @override
  Widget build(BuildContext context) {
    BobaMapBloc bloc = BlocProvider.of<BobaMapBloc>(context);
    Color color = Color.fromARGB(widget._shop.color.a, widget._shop.color.r,
        widget._shop.color.g, widget._shop.color.b);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: StreamBuilder<List<String>>(
        stream: bloc.filterShopList,
        builder: (context, snapshot) {
          List<String> filteredShops = snapshot.data ?? [];
          bool isFiltered = filteredShops.contains(widget._shop.name);
          return RaisedButton(
            color: isFiltered ? color : Colors.white,
            textColor: isFiltered ? Colors.white : color,
            shape: StadiumBorder(
              side: isFiltered
                  ? BorderSide.none
                  : BorderSide(color: color, width: 1.5),
            ),
            child: Text(widget._shop.name),
            onPressed: () => bloc.filterShop(widget._shop.name),
          );
        },
      ),
    );
  }
}
