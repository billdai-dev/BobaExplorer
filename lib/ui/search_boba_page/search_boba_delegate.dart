import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/data/repo/search_boba/search_boba_repo.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop_repo.dart';
import 'package:boba_explorer/ui/search_boba_page/search_boba_bloc.dart';
import 'package:boba_explorer/util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class SearchBobaDelegate extends SearchDelegate {
  final double _lat;
  final double _lng;
  List<String> _randomShops;
  Tuple2<String, Future<List<TeaShop>>> _searchFutureTuple;

  SearchBobaDelegate(this._lat, this._lng);

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isEmpty) {
      return null;
    }
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Provider<SearchBobaBloc>(
      builder: (_) => SearchBobaBloc(
        SearchBobaRepo(),
        TeaShopRepo(),
      ),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<AppBloc>(
        builder: (context, appBloc, child) {
          return StreamBuilder<List<String>>(
            stream: appBloc.supportedShops
                .map((shops) => shops.map((shop) => shop.name).toList()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              final supportedShops = snapshot.data;
              _randomShops ??= (supportedShops..shuffle())
                  .take((supportedShops.length / 3.0).round())
                  .toList();
              final shops = query.isEmpty
                  ? _randomShops
                  : supportedShops
                      .where((shopName) => shopName.contains(query))
                      .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (query.isEmpty)
                    Consumer<SearchBobaBloc>(
                      builder: (context, bloc, child) {
                        return StreamBuilder<List<String>>(
                          stream: bloc.recentSearch,
                          builder: (context, snapshot) {
                            final shops = snapshot.data ?? [];

                            return Container(
                              color: Colors.grey.shade100,
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.history,
                                        color: Colors.black26,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "歷史搜尋紀錄",
                                        style: TextStyle(color: Colors.black26),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 0,
                                    children: shops.map((shop) {
                                      //String shopName = shop.shopName;
                                      return _buildSuggestionTag(shop, () {
                                        query = shop;
                                        showResults(context);
                                      });
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  Expanded(
                    child: _buildSuggestionList(false, shops),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSuggestionTag(String shopName, VoidCallback onPressed) {
    return ActionChip(
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade300),
      ),
      backgroundColor: Colors.grey.shade100,
      label: Text(shopName),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      onPressed: onPressed,
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Provider<SearchBobaBloc>(
      builder: (_) {
        final bloc = SearchBobaBloc(
          SearchBobaRepo(),
          TeaShopRepo(),
        );
        if (query.isNotEmpty) {
          bloc.addRecentSearch(query);
        }
        return bloc;
      },
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<AppBloc>(
        builder: (context, appBloc, child) {
          return StreamBuilder<List<String>>(
            stream: appBloc.supportedShops
                .map((shops) => shops.map((shop) => shop.name).toList()),
            builder: (context, snapshot) {
              final supportedShops = snapshot.data ?? [];

              String target = supportedShops.firstWhere(
                  (name) => name.toLowerCase().contains(query.toLowerCase()),
                  orElse: () => null);
              if (target == null) {
                return Container(
                  alignment: Alignment(0, -0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.grey,
                      ),
                      Text(
                        "查無相關店家",
                        style: Theme.of(context)
                            .textTheme
                            .headline
                            .copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return Consumer<SearchBobaBloc>(
                builder: (context, searchBloc, child) {
                  if (_searchFutureTuple == null ||
                      _searchFutureTuple.item1 != query) {
                    _searchFutureTuple = Tuple2(
                        query,
                        searchBloc.searchTeaShop(target,
                            lat: _lat, lng: _lng, radius: 0.5));
                  }
                  return FutureBuilder<List<TeaShop>>(
                    future: _searchFutureTuple.item2,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Container(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            height: 3,
                            child: LinearProgressIndicator(),
                          ),
                        );
                      }
                      final shops = snapshot.data ?? [];
                      print(shops);
                      return Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: _buildResultList(context, shops),
                          ),
                          if (shops.isNotEmpty)
                            Positioned.fill(
                              child: Container(
                                alignment: Alignment(0, 0.9),
                                child: FloatingActionButton.extended(
                                  onPressed: () => close(context, target),
                                  icon: Icon(FontAwesomeIcons.mapMarkedAlt),
                                  label: Text("在地圖上查看"),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSuggestionList(bool isShowingResult, List<String> shops) {
    return ListView.separated(
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(height: 0),
      ),
      itemBuilder: (context, index) {
        final shopName = shops[index];
        final List<TextSpan> spans = [];
        shopName.split(query).forEach((name) {
          spans.add(TextSpan(
            text: name,
            style: TextStyle(color: Colors.black87),
          ));
          spans.add(TextSpan(
            text: query,
            style: TextStyle(color: Colors.blueAccent),
          ));
        });
        spans.removeLast();

        return ListTile(
          title: RichText(
            text: TextSpan(children: spans),
          ),
          onTap: () {
            if (isShowingResult) {
              close(context, shopName);
            } else {
              query = shopName;
              showResults(context);
            }
          },
        );
      },
      itemCount: shops.length,
    );
  }

  Widget _buildResultList(BuildContext context, List<TeaShop> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            "搜尋結果",
            style:
                Theme.of(context).textTheme.body2.copyWith(color: Colors.grey),
          ),
        ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final shop = results[index];
              return _buildResultItem(context, shop);
            },
            separatorBuilder: (context, index) => Divider(height: 0),
            itemCount: results.length,
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(BuildContext context, TeaShop shop) {
    String branchName = shop.branchName;
    branchName = branchName.endsWith("店") && !branchName.endsWith("新店")
        ? branchName
        : "$branchName店";
    String address = '${shop.city}${shop.district}${shop.address}';
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.grey),
            SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        shop.shopName,
                        style: Theme.of(context).textTheme.subhead,
                      ),
                      Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: ShapeDecoration(
                          shape: StadiumBorder(
                            side: BorderSide(width: 0.5, color: Colors.brown),
                          ),
                        ),
                        child: Text(
                          branchName,
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .copyWith(color: Colors.brown),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    address,
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            GestureDetector(
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  color: Colors.blue.shade400,
                ),
                child: Icon(
                  FontAwesomeIcons.locationArrow,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              onTap: () => Util.launchMap(address),
            ),
          ],
        ),
      ),
    );
  }
}
