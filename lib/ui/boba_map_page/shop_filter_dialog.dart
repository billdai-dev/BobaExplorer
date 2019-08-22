import 'package:boba_explorer/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopFilterDialog extends StatefulWidget {
  final Set<String> _filteredShops;

  ShopFilterDialog(this._filteredShops, {Key key}) : super(key: key);

  @override
  _ShopFilterDialogState createState() => _ShopFilterDialogState();
}

class _ShopFilterDialogState extends State<ShopFilterDialog> {
  AppBloc appBloc;
  ValueNotifier<bool> isAllCheckedNotifier;
  ValueNotifier<Set<String>> filteredShopsNotifier;

  @override
  void initState() {
    super.initState();
    appBloc = Provider.of<AppBloc>(context, listen: false);
    isAllCheckedNotifier = ValueNotifier(widget._filteredShops.isEmpty);
    filteredShopsNotifier = ValueNotifier(Set.of(widget._filteredShops ?? {}));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widthMargin = screenWidth * 0.05 / 2;
    double screenHeight = MediaQuery.of(context).size.height;
    double heightMargin = screenHeight * 0.2 / 2;
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: widthMargin, vertical: heightMargin),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: StreamBuilder<List<String>>(
            stream: appBloc.supportedShops
                .map((shops) => shops.map((shop) => shop.name).toList()),
            builder: (context, supportedShopsData) {
              List<String> supportedShops = supportedShopsData.hasData
                  ? supportedShopsData.data.toList()
                  : [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    child: Text(
                      "選擇你想找的飲料店",
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Divider(height: 16),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: filteredShopsNotifier,
                    builder: (context, filteredShops, child) {
                      bool isAllChecked = isAllCheckedNotifier.value;
                      if (filteredShops.isNotEmpty) {
                        for (var shop in supportedShops) {
                          isAllChecked &= filteredShops.contains(shop);
                        }
                      }
                      isAllCheckedNotifier.value = isAllChecked;
                      return _buildCheckbox(isAllChecked, "全選", (isChecked) {
                        if (isChecked) {
                          filteredShopsNotifier?.value = {};
                        } else {
                          //Add a fake item to deselect all
                          filteredShopsNotifier?.value = {""};
                        }
                        isAllCheckedNotifier.value = isChecked;
                      });
                    },
                  ),
                  Expanded(
                    child: _buildSupportedShopGrid(supportedShops),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child:
                              Text("取消", style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      Expanded(
                        child: ValueListenableBuilder<Set<String>>(
                          valueListenable: filteredShopsNotifier,
                          builder: (context, filters, child) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: isAllCheckedNotifier,
                              builder: (context, isAllChecked, child) {
                                final filters = filteredShopsNotifier.value;
                                bool isDisabled = !isAllChecked &&
                                    (filters.isEmpty ||
                                        filters.length == 1 &&
                                            filters.contains(""));
                                return FlatButton(
                                  textColor: Colors.blueAccent,
                                  disabledTextColor: Colors.grey.shade700,
                                  onPressed: isDisabled
                                      ? null
                                      : () {
                                          final filters =
                                              filteredShopsNotifier.value;
                                          if (filters.isEmpty) {}
                                          return Navigator.pop(context,
                                              filteredShopsNotifier.value);
                                        },
                                  child: child,
                                );
                              },
                              child: Text(
                                "確定",
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(
      bool isChecked, String title, Function(bool) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Checkbox(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: isChecked,
          onChanged: onChanged,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!isChecked),
            child: Text(title),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportedShopGrid(List<String> supportedShops) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Container(
          height: constraint.maxHeight,
          child: GridView.builder(
            itemCount: supportedShops?.length ?? 0,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2,
            ),
            itemBuilder: (context, index) {
              return ValueListenableBuilder<bool>(
                valueListenable: isAllCheckedNotifier,
                builder: (context, isAllChecked, child) {
                  return ValueListenableBuilder(
                    valueListenable: filteredShopsNotifier,
                    builder: (context, filteredShops, child) {
                      final shopName = supportedShops[index];
                      bool isChecked =
                          isAllChecked || filteredShops.contains(shopName);

                      var onCheckChanged = (isChecked) {
                        final newFilterList =
                            Set.of(filteredShopsNotifier.value);
                        if (isChecked) {
                          //Remove fake item added by "Select all" checkbox if exists
                          newFilterList.remove("");
                          newFilterList.add(shopName);
                        } else {
                          if (isAllChecked) {
                            newFilterList.addAll(supportedShops);
                          }
                          newFilterList.remove(shopName);
                          isAllCheckedNotifier.value = false;
                        }
                        filteredShopsNotifier?.value = newFilterList;
                      };
                      return _buildCheckbox(
                          isChecked, shopName, onCheckChanged);
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
