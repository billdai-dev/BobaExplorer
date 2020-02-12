import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/data/repository/mapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopFilterDialog extends StatefulWidget {
  final Set<String> _filteredShops;

  ShopFilterDialog(this._filteredShops, {Key key}) : super(key: key);

  @override
  _ShopFilterDialogState createState() => _ShopFilterDialogState();
}

class _ShopFilterDialogState extends State<ShopFilterDialog>
    with SingleTickerProviderStateMixin {
  AppBloc appBloc;
  ValueNotifier<bool> isAllCheckedNotifier;
  ValueNotifier<Set<String>> filteredShopsNotifier;
  AnimationController _animController;

  @override
  void initState() {
    super.initState();
    appBloc = Provider.of<AppBloc>(context, listen: false);
    isAllCheckedNotifier = ValueNotifier(widget._filteredShops.isEmpty);
    filteredShopsNotifier = ValueNotifier(Set.of(widget._filteredShops ?? {}));
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widthMargin = screenWidth * 0.05 / 2;
    double screenHeight = MediaQuery.of(context).size.height;
    double heightMargin = screenHeight * 0.2 / 2;
    return WillPopScope(
      onWillPop: () async {
        await _animController.reverse();
        return true;
      },
      child: ScaleTransition(
        scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: widthMargin, vertical: heightMargin),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: StreamBuilder<List<String>>(
                stream: appBloc.supportedShops
                    .map((shops) => Mapper.rcShopToStrings(shops)),
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
                      buildAllCheckedButton(supportedShops),
                      Expanded(
                        child: _buildSupportedShopGrid(supportedShops),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: buildCancelButton(context),
                          ),
                          Expanded(
                            child: buildConfirmButton(),
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAllCheckedButton(List<String> supportedShops) {
    return ValueListenableBuilder<bool>(
      valueListenable: isAllCheckedNotifier,
      builder: (context, isAllChecked, child) {
        final filters = Set.of(filteredShopsNotifier.value);
        if (filters.isNotEmpty) {
          isAllChecked = true;
          for (var shop in supportedShops) {
            isAllChecked &= filters.contains(shop);
          }
        }
        return _buildCheckbox(isAllChecked, "全選", (isChecked) {
          if (isChecked) {
            filteredShopsNotifier?.value = {};
          }
          isAllCheckedNotifier.value = isChecked;
        });
      },
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
                          newFilterList.add(shopName);
                        } else {
                          if (isAllChecked) {
                            //The set will exclude shops already in the filter list
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

  FlatButton buildCancelButton(BuildContext context) {
    return FlatButton(
      onPressed: () async {
        await _animController?.reverse();
        return Navigator.pop(context);
      },
      child: Text("取消", style: TextStyle(color: Colors.grey)),
    );
  }

  ValueListenableBuilder<Set<String>> buildConfirmButton() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: filteredShopsNotifier,
      builder: (context, filters, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isAllCheckedNotifier,
          builder: (context, isAllChecked, child) {
            final filters = filteredShopsNotifier.value;
            bool isDisabled = !isAllChecked &&
                (filters.isEmpty ||
                    filters.length == 1 && filters.contains(""));
            var onPressed;
            if (!isDisabled) {
              onPressed = () async {
                await _animController?.reverse();
                return Navigator.pop(context, filteredShopsNotifier.value);
              };
            }
            return FlatButton(
              textColor: Colors.blueAccent,
              disabledTextColor: Colors.grey.shade700,
              onPressed: onPressed,
              child: child,
            );
          },
          child: Text(
            "確定",
          ),
        );
      },
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
}
