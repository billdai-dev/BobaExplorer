import 'dart:async';

import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/remote_config_model.dart';
import 'package:boba_explorer/ui/boba_map_page/boba_map_bloc.dart';
import 'package:boba_explorer/ui/boba_map_page/shop_filter_dialog.dart';
import 'package:boba_explorer/ui/custom_widget.dart';
import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:boba_explorer/ui/login/login_dialog.dart';
import 'package:boba_explorer/ui/report/report_dialog.dart';
import 'package:boba_explorer/ui/search_boba_page/search_boba_delegate.dart';
import 'package:boba_explorer/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

Future<FirebaseUser> showLoginDialog(BuildContext context) async {
  final user = await showDialog<FirebaseUser>(
    context: context,
    builder: (context) => LoginDialog(),
  );
  if (user != null) {
    String userName = user.displayName ?? "";
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("歡迎，$userName，現在您可以收藏店家囉"),
    ));
  }
  return user;
}

class BobaMap extends StatefulWidget {
  static const String routeName = "/";

  BobaMap({Key key}) : super(key: key);

  @override
  _BobaMapState createState() => _BobaMapState();
}

class _BobaMapState extends State<BobaMap> with SingleTickerProviderStateMixin {
  static const _tw101 = const LatLng(25.0339639, 121.5622835);
  BobaMapBloc _bobaMapBloc;

  ValueNotifier<bool> _isMapCreatedNotifier = ValueNotifier(false);
  GoogleMapController _mapController;
  CameraPosition _cameraPos;
  Set<Marker> _markers;
  LatLng _userLocation;
  ValueNotifier<bool> _isCameraTooFarNotifier = ValueNotifier(true);
  ValueNotifier<bool> _searchBtnVisibilityNotifier = ValueNotifier(false);
  PageController _shopInfoPageController;
  bool _shouldBlockNextMove = false;
  bool _shouldJumpToFirstPage = false;

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
    _shopInfoPageController?.dispose();
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          endDrawer: FavoriteDrawer((shop) {
            _shouldJumpToFirstPage = true;
            _bobaMapBloc.searchSingleShop(shop);
          }),
          resizeToAvoidBottomInset: false,
          appBar: _buildAppBar(),
          body: Column(
            children: <Widget>[
              _buildShopFilterBar(),
              Expanded(
                child: StreamBuilder<List<TeaShop>>(
                  stream: _bobaMapBloc?.teaShops,
                  builder: (ctx, snapshot) {
                    List<TeaShop> teaShops = snapshot.data;
                    _markers = _genMarkers(teaShops);

                    //Jump to first page after data changed
                    if (_shouldJumpToFirstPage) {
                      Future(() {
                        if (teaShops != null && teaShops.isNotEmpty) {
                          _shouldBlockNextMove = true;
                          _shouldJumpToFirstPage = false;
                          if (_shopInfoPageController.page.round() != 0) {
                            _shopInfoPageController?.jumpToPage(0);
                          } else {
                            _moveCamera(teaShops[0].position?.latitude,
                                teaShops[0].position?.longitude);
                          }
                        }
                      });
                    }

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
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isMapCreatedNotifier,
          builder: (context, isMapCreated, child) =>
              LoadingWidget(isLoading: !isMapCreated),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: <Widget>[SizedBox.shrink()],
      backgroundColor: Colors.white,
      elevation: 0,
      title: Container(
        width: double.infinity,
        height: 50,
        child: GestureDetector(
          onTap: () async {
            var result = await showSearch(
              context: context,
              delegate: SearchBobaDelegate(
                  _userLocation?.latitude, _userLocation?.longitude),
            );
            if (result == null) {
              return;
            }
            _shouldJumpToFirstPage = true;
            if (result is TeaShop) {
              _bobaMapBloc.searchSingleShop(result);
            } else if (result is String && result.isNotEmpty) {
              _bobaMapBloc?.filter(shops: {result});
            }
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            child: Consumer<LoginBloc>(
              builder: (context, loginBloc, child) {
                return Row(
                  children: <Widget>[
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => showLoginDialog(context),
                      child: _buildAvatar(loginBloc),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "搜尋飲料店",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    StreamBuilder<FirebaseUser>(
                      stream: loginBloc.currentUser,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.none) {
                          return Container();
                        }
                        return IconButton(
                          icon: Icon(Icons.favorite, color: Colors.redAccent),
                          onPressed: () async {
                            if (snapshot.data == null) {
                              final newUser = await showLoginDialog(context);
                              if (newUser == null) {
                                return;
                              }
                            }
                            Scaffold.of(context).openEndDrawer();
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  StreamBuilder<FirebaseUser> _buildAvatar(LoginBloc loginBloc) {
    return StreamBuilder<FirebaseUser>(
      stream: loginBloc.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        var child;
        var avatar;
        if (user == null) {
          child = Icon(
            FontAwesomeIcons.solidUserCircle,
            color: Colors.grey,
          );
        } else if (user.isAnonymous) {
          child = Container(
            decoration: ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(color: Colors.grey),
              ),
            ),
            child: ClipOval(
              child: Icon(
                FontAwesomeIcons.userSecret,
                color: Colors.grey,
              ),
            ),
          );
        } else if (user.photoUrl == null) {
          child = Text(user.displayName ?? "");
        } else {
          avatar = CachedNetworkImageProvider(user.photoUrl);
        }
        return CircleAvatar(
          minRadius: 15,
          maxRadius: 18,
          backgroundColor:
              user == null || user.isAnonymous ? Colors.transparent : null,
          backgroundImage: avatar,
          child: child,
        );
      },
    );
  }

  Widget _buildShopFilterBar() {
    return Container(
      height: 50,
      color: Colors.white12,
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
                      padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                      itemBuilder: (context, index) {
                        return ShopFilterButton(
                          shops[index],
                          key: ValueKey(shops[index].name),
                        );
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
              _shouldJumpToFirstPage = true;
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
                  _shouldJumpToFirstPage = true;
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
        //_isMapCreatedNotifier.value = true;
        _mapController = controller;
        _markerIcon = await _markerIconCompleter.future;
        _userLocation = await Geolocator()
            .getCurrentPosition()
            .then((pos) =>
                pos == null ? null : LatLng(pos.latitude, pos.longitude))
            .catchError((err) {});
        LatLng pos = _userLocation ?? _tw101;
        controller
            .animateCamera(CameraUpdate.newLatLng(pos))
            .then((_) => _isMapCreatedNotifier.value = true);
        _bobaMapBloc.seekBoba(lat: pos.latitude, lng: pos.longitude);
      },
      markers: markers,
      onCameraMoveStarted: () {
        if (_shouldBlockNextMove) {
          _shouldBlockNextMove = false;
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
              return _ShopItem(shop, () {
                _moveCamera(shop.position.latitude, shop.position.longitude);
              });
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

class FavoriteDrawer extends StatefulWidget {
  final Function(TeaShop shop) onFavoriteItemClick;

  FavoriteDrawer(this.onFavoriteItemClick);

  @override
  _FavoriteDrawerState createState() => _FavoriteDrawerState();
}

class _FavoriteDrawerState extends State<FavoriteDrawer> {
  BobaMapBloc bobaMapBloc;

  @override
  void initState() {
    super.initState();
    bobaMapBloc = Provider.of<BobaMapBloc>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.6),
        child: Drawer(
          child: StreamBuilder<List<TeaShop>>(
            stream: bobaMapBloc.favoriteShops,
            builder: (context, snapshot) {
              Map<String, List<TeaShop>> favoriteMap = snapshot.hasData
                  ? snapshot.data.fold({}, (map, shop) {
                      String name = shop.shopName;
                      if (map.containsKey(name)) {
                        map[name].add(shop);
                      } else {
                        map[name] = [shop];
                      }
                      return map;
                    })
                  : {};
              return Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.centerLeft,
                    width: double.infinity,
                    color: Colors.blueGrey.shade500,
                    child: Text(
                      "收藏列表",
                      style: Theme.of(context)
                          .textTheme
                          .subhead
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.blueGrey.shade600,
                      child: CustomScrollView(
                        slivers: favoriteMap.keys
                            .map((name) =>
                                _buildHeader(context, name, favoriteMap[name]))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String shopName, List<TeaShop> shops) {
    return SliverStickyHeader(
      header: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: Alignment.center,
        color: Colors.grey.shade300,
        child: Text(
          shopName,
          style: Theme.of(context).textTheme.subhead,
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildFavoriteItem(context, shops[index]),
          childCount: shops?.length ?? 0,
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, TeaShop shop) {
    String branchName = shop.branchName;
    branchName = branchName.endsWith("店") && !branchName.endsWith("新店")
        ? branchName
        : "$branchName店";
    String address = '${shop.city}${shop.district}${shop.address}';
    return Dismissible(
      key: ValueKey(shop.docId),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {},
      confirmDismiss: (direction) async {
        await bobaMapBloc.setFavoriteShop(false, shop);
        return true;
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            widget.onFavoriteItemClick(shop);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: ShapeDecoration(
                        shape: StadiumBorder(
                          side: BorderSide(color: Colors.brown, width: 0.5),
                        ),
                      ),
                      child: Text(
                        branchName,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle
                            .copyWith(color: Colors.brown),
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () async {
                        await bobaMapBloc.setFavoriteShop(false, shop);
                      },
                      child: Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(address),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShopFilterButton extends StatefulWidget {
  final Shop _shop;

  ShopFilterButton(this._shop, {Key key}) : super(key: key);

  @override
  _ShopFilterButtonState createState() => _ShopFilterButtonState();
}

class _ShopFilterButtonState extends State<ShopFilterButton>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController _controller;
  Animation _anim;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1));
    _anim = Tween<double>(begin: 0, end: 12).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutExpo));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    BobaMapBloc bloc = Provider.of<BobaMapBloc>(context, listen: false);
    Color color = Color.fromARGB(widget._shop.color.a, widget._shop.color.r,
        widget._shop.color.g, widget._shop.color.b);
    double brightness = Util.getGrayLevel(color: color);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: StreamBuilder<Set<String>>(
        stream: bloc.filterList,
        builder: (context, snapshot) {
          Set<String> filteredShops = snapshot.data ?? {};
          bool isSelected = filteredShops.contains(widget._shop.name);
          _controller.value = isSelected ? 1.0 : 0.0;
          return AnimatedBuilder(
            animation: _anim,
            builder: (context, child) {
              return RaisedButton(
                elevation: _anim.value,
                splashColor: Colors.transparent,
                highlightElevation: 0,
                highlightColor: Colors.transparent,
                color: isSelected
                    ? color.withOpacity(0.8)
                    : Theme.of(context).canvasColor,
                textColor: isSelected
                    ? brightness < 0.5 ? Colors.white : Colors.grey.shade700
                    : Colors.grey,
                shape: StadiumBorder(),
                child: Text(widget._shop.name),
                onPressed: () {
                  if (_controller.isDismissed) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                  bloc.filter(shop: widget._shop.name);
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;
}

class _ShopItem extends StatefulWidget {
  final TeaShop _shop;
  final VoidCallback _onTap;

  _ShopItem(this._shop, this._onTap);

  @override
  _ShopItemState createState() => _ShopItemState();
}

class _ShopItemState extends State<_ShopItem> {
  final ValueNotifier<bool> isCardTappingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    BobaMapBloc bloc = Provider.of<BobaMapBloc>(context, listen: false);
    /*Color color = _hue == null
        ? Colors.redAccent
        : HSVColor.fromAHSV(1, _hue.toDouble(), 1, 1).toColor();*/
    String shopName = widget._shop.shopName;
    String branchName = widget._shop.branchName;
    branchName = branchName.endsWith("店") && !branchName.endsWith("新店")
        ? branchName
        : "$branchName店";
    String city = widget._shop.city;
    String district = widget._shop.district;
    String address = widget._shop.address;
    String phone = widget._shop.phone;

    return GestureDetector(
      onTap: widget._onTap,
      onTapDown: (detail) => isCardTappingNotifier.value = true,
      onTapUp: (detail) => isCardTappingNotifier.value = false,
      onTapCancel: () => isCardTappingNotifier.value = false,
      child: ValueListenableBuilder(
        valueListenable: isCardTappingNotifier,
        builder: (context, isCardTapping, child) {
          return Card(
            elevation: isCardTapping ? 24 : 2,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                    teaShop: widget._shop),
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
                            onPressed: () =>
                                Util.launchMap("$city$district$address"),
                            icon: Icon(
                              FontAwesomeIcons.locationArrow,
                              size: 18,
                            ),
                            label: Text("在地圖上查看"),
                          ),
                        ),
                        Container(
                          width: 54,
                          child: FavoriteCheckbox(
                            key: UniqueKey(),
                            isFavorite: widget._shop.isFavorite,
                            onFavoriteChanged: (isFavorite) {
                              bloc.setFavoriteShop(isFavorite, widget._shop);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  Widget buildPopupMenuButton(String text, {IconData icon}) {
    return Column(
      children: <Widget>[
        if (icon != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon),
              SizedBox(width: 8),
              Text(text),
            ],
          )
        else
          Text(text),
        SizedBox(height: 8),
        Divider(height: 0),
      ],
    );
  }

  Future<void> _handleOverflowAction(_ShopOverflowOption option,
      {String shopName = "",
      String branchName = "",
      String address = "",
      TeaShop teaShop}) async {
    if (option == _ShopOverflowOption.share) {
      String googleMapUrl =
          "https://www.google.com/maps/search/?api=1&query=$address";
      googleMapUrl = Uri.encodeFull(googleMapUrl);
      await Share.share("$shopName, $branchName\n$googleMapUrl");
    } else if (option == _ShopOverflowOption.report) {
      showDialog(
        context: context,
        builder: (context) => ReportShopDialog(teaShop),
      );
    }
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

class FavoriteCheckbox extends StatefulWidget {
  final bool _isFavorite;
  final Function(bool isFavorite) _onFavoriteChanged;

  FavoriteCheckbox(
      {Key key, @required isFavorite, @required Function onFavoriteChanged})
      : this._isFavorite = isFavorite,
        _onFavoriteChanged = onFavoriteChanged,
        super(key: key);

  @override
  _FavoriteCheckboxState createState() => _FavoriteCheckboxState();
}

class _FavoriteCheckboxState extends State<FavoriteCheckbox> {
  bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget._isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginBloc>(
      builder: (context, loginBloc, child) {
        return StreamBuilder<FirebaseUser>(
          stream: loginBloc.currentUser,
          builder: (context, snapshot) {
            final user = snapshot.data;
            return GestureDetector(
              onTap: () async {
                if (user == null) {
                  final newUser = await showLoginDialog(context);
                  if (newUser == null) {
                    return;
                  }
                }
                isFavorite = !isFavorite;
                widget._onFavoriteChanged(isFavorite);
                setState(() {});
              },
              child: CustomPaint(
                painter: _FavoriteStampCustomPainter(),
                child: Container(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent.shade200,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
