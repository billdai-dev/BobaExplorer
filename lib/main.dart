import 'package:boba_explorer/boba_map_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BobaMap(BobaMapBloc()),
    ));

class BobaMap extends StatefulWidget {
  final BobaMapBloc bloc;

  BobaMap(this.bloc, {Key key}) : super(key: key);

  @override
  _BobaMapState createState() => _BobaMapState();
}

class _BobaMapState extends State<BobaMap> {
  static const _tw101 = LatLng(25.0339639, 121.5622835);
  GoogleMapController _mapController;
  CameraPosition _cameraPos;
  Set<Marker> _markers;
  bool _isCameraTooFar = false;

  @override
  void dispose() {
    widget.bloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BobaMapBloc bloc = widget.bloc;
    return Scaffold(
      appBar: AppBar(
        title: Text('BobaExplorer'),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
          stream: bloc?.bobaData,
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
                bloc.seekBoba(pos.latitude, pos.longitude);
              },
              markers: _isCameraTooFar || !snapshot.hasData ? null : _markers,
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
      floatingActionButton: FloatingActionButton.extended(
          label: Text("Search"),
          icon: Icon(Icons.search),
          onPressed: () {
            if (_cameraPos == null) {
              return;
            }
            LatLng latLng = _cameraPos.target;
            bloc.seekBoba(latLng.latitude, latLng.longitude);
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
      double hue;
      switch (shop) {
        case "50嵐":
          hue = 61;
          break;
        case "迷客夏":
          hue = 91;
          break;
        case "大苑子":
          hue = 85;
          break;
      }
      GeoPoint geo = data.data["position"]["geopoint"];
      final pos = LatLng(geo.latitude, geo.longitude);
      return Marker(
          markerId: MarkerId(data.documentID),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
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
