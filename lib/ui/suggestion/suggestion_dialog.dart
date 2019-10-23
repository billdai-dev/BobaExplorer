import 'dart:math';

import 'package:boba_explorer/data/repo/city_data.dart';
import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:boba_explorer/ui/suggestion/suggestion_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SuggestionDialog extends StatefulWidget {
  @override
  _SuggestionDialogState createState() => _SuggestionDialogState();
}

class _SuggestionDialogState extends State<SuggestionDialog> {
  ValueNotifier<_SuggestionType> suggestionTypeNotifier;

  ValueNotifier<bool> isBugReportValidNotifier;
  GlobalKey<FormState> bugReportFormKey;
  TextEditingController bugDescTextController;
  ValueNotifier<_BugSeverity> bugSeverityNotifier;

  ValueNotifier<bool> isWishValidNotifier;
  GlobalKey<FormState> wishFormKey;
  TextEditingController wishShopController;
  ValueNotifier<String> wishShopNotifier;
  ValueNotifier<City> cityNotifier;
  ValueNotifier<String> districtNotifier;

  ValueNotifier<bool> isOpinionValidNotifier;

  @override
  void initState() {
    super.initState();
    suggestionTypeNotifier = ValueNotifier(null);

    isBugReportValidNotifier = ValueNotifier(false);
    bugReportFormKey = GlobalKey();
    bugDescTextController = TextEditingController();
    bugSeverityNotifier = ValueNotifier(_BugSeverity.light);

    isWishValidNotifier = ValueNotifier(false);
    wishFormKey = GlobalKey();
    wishShopNotifier = ValueNotifier(null);
    cityNotifier = ValueNotifier(null);
    districtNotifier = ValueNotifier(null);
  }

  @override
  void dispose() {
    suggestionTypeNotifier?.dispose();
    isBugReportValidNotifier?.dispose();
    bugDescTextController?.dispose();
    bugSeverityNotifier?.dispose();
    isWishValidNotifier?.dispose();
    wishShopNotifier?.dispose();
    cityNotifier?.dispose();
    districtNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Provider<SuggestionBloc>(
      builder: (context) => SuggestionBloc(
          context, Provider.of<LoginBloc>(context, listen: false)),
      dispose: (_, bloc) => bloc.dispose(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraint) {
            return Container(
              padding: const EdgeInsets.all(12),
              height: min(screenHeight * 0.58, constraint.maxHeight),
              child: DropdownButtonHideUnderline(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {},
                                    child: Icon(Icons.arrow_back),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "我有話要說 ( ～'ω')～",
                                    style: Theme.of(context).textTheme.title,
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                "問題類型",
                                style: Theme.of(context).textTheme.subtitle,
                              ),
                              SizedBox(height: 4),
                              Container(
                                height: 40,
                                decoration: ShapeDecoration(
                                  color: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: ValueListenableBuilder<_SuggestionType>(
                                  valueListenable: suggestionTypeNotifier,
                                  builder: (context, suggestionType, child) {
                                    return DropdownButton<_SuggestionType>(
                                      hint: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text("請選擇問題類型"),
                                      ),
                                      value: suggestionType,
                                      items:
                                          _SuggestionType.values.map((option) {
                                        String text;
                                        switch (option) {
                                          case _SuggestionType.bugReport:
                                            text = "Bug 回報";
                                            break;
                                          case _SuggestionType.wish:
                                            text = "向作者許願";
                                            break;
                                          case _SuggestionType.opinion:
                                            text = "提供意見、建議";
                                            break;
                                        }
                                        return DropdownMenuItem(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Text(text),
                                          ),
                                          value: option,
                                        );
                                      }).toList(),
                                      onChanged: (value) =>
                                          suggestionTypeNotifier.value = value,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 12),
                              ValueListenableBuilder<_SuggestionType>(
                                valueListenable: suggestionTypeNotifier,
                                builder: (context, suggestionType, child) {
                                  if (suggestionType == null) {
                                    return Container();
                                  }
                                  return IndexedStack(
                                    sizing: StackFit.passthrough,
                                    index: _SuggestionType.values
                                        .indexOf(suggestionType),
                                    children: <Widget>[
                                      _buildBugReportContent(),
                                      _buildWishShopContent(),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<_SuggestionType>(
      valueListenable: suggestionTypeNotifier,
      builder: (context, suggestionType, child) {
        //VoidCallback onPressed;
        ValueNotifier<bool> notifier;
        switch (suggestionType) {
          case _SuggestionType.bugReport:
            notifier = isBugReportValidNotifier;
            break;
          case _SuggestionType.wish:
            notifier = isWishValidNotifier;
            break;
          case _SuggestionType.opinion:
            break;
          default:
            return Container();
        }
        return ValueListenableBuilder(
          valueListenable: notifier,
          builder: (context, isValid, child) {
            return Container(
              width: double.infinity,
              child: RaisedButton(
                disabledTextColor: Colors.grey.shade700,
                disabledColor: Colors.grey.shade300,
                shape: StadiumBorder(),
                elevation: 8,
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                child: Text(
                  "送出回饋",
                ),
                onPressed: isValid ? () {} : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBugReportContent() {
    return Container(
      child: Form(
        key: bugReportFormKey,
        onChanged: () {
          isBugReportValidNotifier.value =
              bugReportFormKey.currentState.validate();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("錯誤簡述*"),
            TextFormField(
              controller: bugDescTextController,
              minLines: 1,
              maxLines: 3,
              validator: (value) => value.isNotEmpty ? null : "必填",
              decoration: InputDecoration(
                hintText: "請簡單描述您遇到的問題",
                helperText: "ex: App 閃退？功能出錯？畫面跑版？",
              ),
            ),
            SizedBox(height: 12),
            Text("嚴重程度"),
            SizedBox(height: 20),
            ValueListenableBuilder<_BugSeverity>(
              valueListenable: bugSeverityNotifier,
              builder: (context, severity, child) {
                String label;
                Color activeColor;
                switch (severity) {
                  case _BugSeverity.light:
                    label = "輕微，感謝您的回報🕵️‍♂️";
                    activeColor = Colors.lightGreen;
                    break;
                  case _BugSeverity.normal:
                    label = "中等，工程師將儘速調查👨‍💻";
                    activeColor = Colors.yellow.shade800;
                    break;
                  case _BugSeverity.severe:
                    label = "嚴重，列為優先解決，抱歉造成困擾🙇‍♂️";
                    activeColor = Colors.deepOrange;
                    break;
                }
                return Slider(
                  value: _BugSeverity.values.indexOf(severity).toDouble(),
                  label: label,
                  divisions: 2,
                  min: 0,
                  max: 2,
                  activeColor: activeColor,
                  inactiveColor: Colors.grey.shade300,
                  onChanged: (value) {
                    return bugSeverityNotifier.value =
                        _BugSeverity.values[value.toInt()];
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWishShopContent() {
    return Container(
      child: Form(
        key: wishFormKey,
        onChanged: () {
          isWishValidNotifier.value = wishFormKey.currentState.validate();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("我的願望*"),
            TextFormField(
              controller: wishShopController,
              validator: (value) => value.trim().isNotEmpty ? null : "必填",
              decoration: InputDecoration(
                hintText: "請填寫希望增加的店家 / 功能",
              ),
            ),
            SizedBox(height: 8),
            Consumer<SuggestionBloc>(
              builder: (context, bloc, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text("縣市"),
                          SizedBox(height: 4),
                          Container(
                            height: 35,
                            decoration: ShapeDecoration(
                              color: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: StreamBuilder<List<City>>(
                              stream: bloc.cities,
                              builder: (context, snapshot) {
                                return ValueListenableBuilder(
                                  valueListenable: cityNotifier,
                                  builder: (context, city, child) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: DropdownButton<City>(
                                        hint: Text("請選擇縣市"),
                                        value: city,
                                        items:
                                            (snapshot.data ?? []).map((city) {
                                          return DropdownMenuItem(
                                            value: city,
                                            child: Text(city.name),
                                          );
                                        }).toList(),
                                        onChanged: (city) {
                                          districtNotifier.value = null;
                                          cityNotifier.value = city;
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text("地區"),
                          SizedBox(height: 4),
                          Container(
                            height: 35,
                            decoration: ShapeDecoration(
                              color: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: ValueListenableBuilder<City>(
                              valueListenable: cityNotifier,
                              builder: (context, city, child) {
                                return ValueListenableBuilder(
                                  valueListenable: districtNotifier,
                                  builder: (context, district, child) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: DropdownButton<String>(
                                        hint: Text("請選擇區域"),
                                        value: district,
                                        items: city?.zone?.map((zone) {
                                          return DropdownMenuItem(
                                            value: zone.name,
                                            child: Text(zone.name),
                                          );
                                        })?.toList(),
                                        onChanged: (district) =>
                                            districtNotifier.value = district,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline, color: Colors.grey.shade400, size: 20),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "願望經過歸納和評估可行性後依照熱門度決定實現順序，無法保證每個願望都能實現\n敬請見諒 🙏",
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(letterSpacing: 0.3),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

enum _SuggestionType { bugReport, wish, opinion }
enum _BugSeverity { light, normal, severe }
