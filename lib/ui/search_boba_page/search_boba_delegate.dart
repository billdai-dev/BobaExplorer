import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/data/repo/favorite/favorite_repo.dart';
import 'package:boba_explorer/data/repo/tea_shop/tea_shop.dart';
import 'package:boba_explorer/ui/search_boba_page/search_boba_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBobaDelegate extends SearchDelegate<String> {
  List<String> _randomShops;

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
      builder: (_) => SearchBobaBloc(FavoriteRepo()),
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
                        return StreamBuilder<List<TeaShop>>(
                          stream: bloc.favoriteShops,
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
                                      String shopName = shop.shopName;
                                      return _buildSuggestionTag(shopName,
                                          () => close(context, shopName));
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
                    child: _buildResultList(shops),
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
    return Consumer<AppBloc>(
      builder: (context, appBloc, child) {
        return StreamBuilder<List<String>>(
            stream: appBloc.supportedShops
                .map((shops) => shops.map((shop) => shop.name).toList()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              final filteredShops = snapshot.data
                  .where((shopName) => shopName.contains(query))
                  .toList();
              return _buildResultList(filteredShops);
            });
      },
    );
  }

  Widget _buildResultList(List<String> shops) {
    /*final filteredShops = snapshot.data
        .where((shopName) => shopName.contains(query))
        .toList();*/
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
          onTap: () => close(context, shopName),
        );
      },
      itemCount: shops.length,
    );
  }
}
