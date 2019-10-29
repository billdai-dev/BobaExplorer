import 'dart:io';
import 'dart:math';

import 'package:boba_explorer/data/repo/city_data.dart';
import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:boba_explorer/ui/suggestion/suggestion_bloc.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
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
  GlobalKey<FormState> opinionFormKey;
  TextEditingController opinionController;

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

    isOpinionValidNotifier = ValueNotifier(false);
    opinionFormKey = GlobalKey();
    opinionController = TextEditingController();
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
    isOpinionValidNotifier?.dispose();
    opinionController?.dispose();
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
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              margin: EdgeInsets.symmetric(horizontal: 4),
              height: min(screenHeight * 0.54, constraint.maxHeight),
              child: DropdownButtonHideUnderline(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "作者悄悄話  ( ～'ω')～",
                          style: Theme.of(context).textTheme.title,
                        ),
                        Spacer(),
                        CloseButton(),
                      ],
                    ),
                    Flexible(
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "問題類型",
                                style: Theme.of(context).textTheme.subhead,
                              ),
                              SizedBox(height: 4),
                              _buildSuggestionDropdown(),
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
                                      _buildOpinionContent(),
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

  Widget _buildSuggestionDropdown() {
    return Container(
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
              child: Text(
                "請選擇問題類型",
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.grey),
              ),
            ),
            value: suggestionType,
            items: _SuggestionType.values.map((option) {
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
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.body1,
                  ),
                ),
                value: option,
              );
            }).toList(),
            onChanged: (value) {
              FocusScope.of(context).requestFocus(FocusNode());
              suggestionTypeNotifier.value = value;
            },
          );
        },
      ),
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
            Text(
              "錯誤簡述*",
              style: Theme.of(context).textTheme.subhead,
            ),
            TextFormField(
              controller: bugDescTextController,
              minLines: 1,
              maxLines: 3,
              validator: (value) => value.isNotEmpty ? null : "必填",
              decoration: InputDecoration(
                hintText: "請簡單描述您遇到的問題",
                hintStyle: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.grey),
                helperText: "ex: App 閃退？功能出錯？畫面跑版？",
              ),
              style: Theme.of(context).textTheme.body1,
            ),
            SizedBox(height: 12),
            Text(
              "嚴重程度",
              style: Theme.of(context).textTheme.subhead,
            ),
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
            Text(
              "我的願望*",
              style: Theme.of(context).textTheme.subhead,
            ),
            TextFormField(
              controller: wishShopController,
              validator: (value) => value.trim().isNotEmpty ? null : "必填",
              style: Theme.of(context).textTheme.body1,
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
                          Text(
                            "縣市",
                            style: Theme.of(context).textTheme.subhead,
                          ),
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
                                        hint: Text(
                                          "請選擇縣市",
                                          style:
                                              Theme.of(context).textTheme.body1,
                                        ),
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
                          Text(
                            "地區",
                            style: Theme.of(context).textTheme.subhead,
                          ),
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
                                        hint: Text(
                                          "請選擇區域",
                                          style:
                                              Theme.of(context).textTheme.body1,
                                        ),
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

  Widget _buildOpinionContent() {
    return Form(
      key: opinionFormKey,
      onChanged: () {
        isOpinionValidNotifier.value = opinionFormKey.currentState.validate();
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text("我的想法", style: Theme.of(context).textTheme.subhead),
            TextFormField(
              controller: opinionController,
              validator: (value) => value.trim().isNotEmpty ? null : "必填",
              style: Theme.of(context).textTheme.body1,
              decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 14),
                hintText: "寫下想法、心得、任何你想告訴作者的話!",
              ),
              maxLines: null,
            ),
            SizedBox(height: 24),
            Text(
              "也歡迎到 ${Platform.isAndroid ? "Google Play" : "App Store"} 打個分數或留下評論!",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .body2
                  .copyWith(color: Colors.grey),
            ),
            SizedBox(height: Platform.isAndroid ? 4 : 12),
            FractionallySizedBox(
              widthFactor: Platform.isAndroid ? 0.7 : 0.58,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {
                    LaunchReview.launch(writeReview: false);
                  },
                  child: Image.asset(
                      "assets/images/${Platform.isAndroid ? "google_play_badge" : "app_store_badge"}.png"),
                ),
              ),
            ),
          ],
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
            notifier = isOpinionValidNotifier;
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
}

enum _SuggestionType { bugReport, wish, opinion }
enum _BugSeverity { light, normal, severe }
