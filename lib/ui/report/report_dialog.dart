import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:boba_explorer/domain/entity/city_data.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/ui/custom_widget.dart';
import 'package:boba_explorer/ui/event.dart';
import 'package:boba_explorer/ui/report/report_bloc.dart';
import 'package:boba_explorer/ui/report/report_event.dart';
import 'package:boba_explorer/util.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';

class ReportDialog extends StatefulWidget {
  final ReportType reportType;

  ReportDialog({this.reportType});

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog>
    with SingleTickerProviderStateMixin {
  StreamSubscription eventSub;
  AnimationController dialogAnimController;

  ValueNotifier<ReportType> reportTypeNotifier;

  ValueNotifier<bool> isBugReportValidNotifier;
  GlobalKey<FormState> bugReportFormKey;
  TextEditingController bugDescTextController;
  ValueNotifier<_BugSeverity> bugSeverityNotifier;

  ValueNotifier<bool> isRequestValidNotifier;
  GlobalKey<FormState> requestFormKey;
  TextEditingController requestController;

  //ValueNotifier<String> requestNotifier;
  ValueNotifier<City> cityNotifier;
  ValueNotifier<String> districtNotifier;

  ValueNotifier<bool> isOpinionValidNotifier;
  GlobalKey<FormState> opinionFormKey;
  TextEditingController opinionController;

  @override
  void initState() {
    super.initState();
    dialogAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..forward();

    reportTypeNotifier = ValueNotifier(widget.reportType);

    isBugReportValidNotifier = ValueNotifier(false);
    bugReportFormKey = GlobalKey();
    bugDescTextController = TextEditingController();
    bugSeverityNotifier = ValueNotifier(_BugSeverity.light);

    isRequestValidNotifier = ValueNotifier(false);
    requestFormKey = GlobalKey();
    requestController = TextEditingController();
    //requestNotifier = ValueNotifier(null);
    cityNotifier = ValueNotifier(null);
    districtNotifier = ValueNotifier(null);

    isOpinionValidNotifier = ValueNotifier(false);
    opinionFormKey = GlobalKey();
    opinionController = TextEditingController();
  }

  @override
  void dispose() {
    dialogAnimController?.dispose();
    reportTypeNotifier?.dispose();

    isBugReportValidNotifier?.dispose();
    bugDescTextController?.dispose();
    bugSeverityNotifier?.dispose();

    isRequestValidNotifier?.dispose();
    requestController?.dispose();
    //requestNotifier?.dispose();
    cityNotifier?.dispose();
    districtNotifier?.dispose();

    isOpinionValidNotifier?.dispose();
    opinionController?.dispose();
    super.dispose();
  }

  void _handleEvent(Event event) {
    switch (event.runtimeType) {
      case OnReportedEvent:
        var isSuccess = (event as OnReportedEvent).isSuccess;
        if (isSuccess == true) {
          Util.showIconTextToast(context, Icons.mail, "回報成功\n感謝您的回饋");
        } else {
          Util.showIconTextToast(context, Icons.sms_failed, "回報失敗\n請稍候再試");
        }
        Navigator.pop(context, isSuccess);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Provider<ReportBloc>(
      builder: (context) {
        var reportBloc = kiwi.Container().resolve<ReportBloc>();
        eventSub = reportBloc.eventStream.listen(_handleEvent);
        return reportBloc;
      },
      dispose: (_, bloc) {
        eventSub?.cancel();
        bloc.dispose();
      },
      child: WillPopScope(
        onWillPop: () async {
          await dialogAnimController.reverse();
          return true;
        },
        child: ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: dialogAnimController,
              curve: Curves.fastOutSlowIn,
            ),
          ),
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
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  "作者悄悄話  ( ～'ω')～",
                                  style: Theme.of(context).textTheme.headline6,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "問題類型",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                      SizedBox(height: 4),
                                      _buildSuggestionDropdown(),
                                      SizedBox(height: 12),
                                      ValueListenableBuilder<ReportType>(
                                        valueListenable: reportTypeNotifier,
                                        builder:
                                            (context, suggestionType, child) {
                                          if (suggestionType == null) {
                                            return Container();
                                          }
                                          return IndexedStack(
                                            sizing: StackFit.passthrough,
                                            index: suggestionType.index,
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
                        Positioned.fill(
                          child: Consumer<ReportBloc>(
                            builder: (context, bloc, child) {
                              return LoadingWidget(
                                isLoadingStream: bloc.isLoading,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
      child: ValueListenableBuilder<ReportType>(
        valueListenable: reportTypeNotifier,
        builder: (context, suggestionType, child) {
          return DropdownButton<ReportType>(
            hint: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "選擇問題類型",
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Colors.grey),
              ),
            ),
            value: suggestionType,
            items: ReportType.values.map((option) {
              String text;
              switch (option) {
                case ReportType.bugReport:
                  text = "Bug 回報";
                  break;
                case ReportType.wish:
                  text = "向作者許願";
                  break;
                case ReportType.opinion:
                  text = "提供意見、建議";
                  break;
              }
              return DropdownMenuItem(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                value: option,
              );
            }).toList(),
            onChanged: (value) {
              FocusScope.of(context).requestFocus(FocusNode());
              reportTypeNotifier.value = value;
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
              style: Theme.of(context).textTheme.subtitle1,
            ),
            TextFormField(
              controller: bugDescTextController,
              minLines: 1,
              maxLines: 3,
              validator: (value) => value.isNotEmpty ? null : "必填",
              decoration: InputDecoration(
                hintText: "簡單描述您遇到的問題",
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Colors.grey),
                helperText: "ex: App 閃退？功能出錯？畫面跑版？",
              ),
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(height: 12),
            Text(
              "嚴重程度",
              style: Theme.of(context).textTheme.subtitle1,
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
                  value: severity.index.toDouble(),
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
        key: requestFormKey,
        onChanged: () {
          isRequestValidNotifier.value = requestFormKey.currentState.validate();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "我的願望*",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            TextFormField(
              controller: requestController,
              validator: (value) => value.trim().isNotEmpty ? null : "必填",
              style: Theme.of(context).textTheme.bodyText2,
              decoration: InputDecoration(
                hintText: "填寫希望增加的店家資料 / 功能",
              ),
            ),
            SizedBox(height: 8),
            Consumer<ReportBloc>(
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
                            style: Theme.of(context).textTheme.subtitle1,
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
                                          "選擇縣市",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
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
                            style: Theme.of(context).textTheme.subtitle1,
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
                                          "選擇地區",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
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
            Text("我的想法", style: Theme.of(context).textTheme.subtitle1),
            TextFormField(
              controller: opinionController,
              validator: (value) => value.trim().isNotEmpty ? null : "必填",
              style: Theme.of(context).textTheme.bodyText2,
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
                  .bodyText1
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
    return Consumer<ReportBloc>(
      builder: (context, reportBloc, child) {
        return ValueListenableBuilder<ReportType>(
          valueListenable: reportTypeNotifier,
          builder: (context, suggestionType, child) {
            ValueNotifier<bool> notifier;
            VoidCallback onPressed;
            switch (suggestionType) {
              case ReportType.bugReport:
                notifier = isBugReportValidNotifier;
                onPressed = () async {
                  String desc = bugDescTextController.text;
                  int severity = bugSeverityNotifier.value.index;
                  reportBloc?.reportBug(desc, severity);
                };
                break;
              case ReportType.wish:
                notifier = isRequestValidNotifier;
                onPressed = () async {
                  String desc = requestController.text;
                  String city = cityNotifier.value?.name;
                  String district = districtNotifier.value;
                  reportBloc?.reportRequest(desc,
                      city: city, district: district);
                };
                break;
              case ReportType.opinion:
                notifier = isOpinionValidNotifier;
                onPressed = () async {
                  String desc = opinionController.text;
                  reportBloc?.reportOpinion(desc);
                };
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
                    child: Text("送出回饋"),
                    onPressed: isValid ? onPressed : null,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ReportShopDialog extends StatefulWidget {
  final TeaShop _shop;

  ReportShopDialog(this._shop);

  @override
  _ReportShopDialogState createState() => _ReportShopDialogState();
}

class _ReportShopDialogState extends State<ReportShopDialog>
    with SingleTickerProviderStateMixin {
  AnimationController _dialogAnimController;
  StreamSubscription<Event> eventSub;
  TextEditingController _shopNameController;
  TextEditingController _branchNameController;
  TextEditingController _cityController;
  TextEditingController _districtController;
  ValueNotifier<_ShopReportItem> _reportItemNotifier;

  @override
  void initState() {
    super.initState();
    _dialogAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..forward();

    _shopNameController = TextEditingController(text: widget._shop.shopName);
    String branchName = widget._shop.branchName;
    branchName = branchName.endsWith("店") && !branchName.endsWith("新店")
        ? branchName
        : "$branchName店";
    _branchNameController = TextEditingController(text: branchName);
    _cityController = TextEditingController(text: widget._shop.city);
    _districtController = TextEditingController(text: widget._shop.district);
    _reportItemNotifier = ValueNotifier(null);
  }

  @override
  void dispose() {
    _dialogAnimController?.dispose();
    _shopNameController?.dispose();
    _branchNameController?.dispose();
    _cityController?.dispose();
    _districtController?.dispose();
    _reportItemNotifier?.dispose();
    super.dispose();
  }

  void _handleEvent(Event event) {
    switch (event.runtimeType) {
      case OnReportedEvent:
        var isSuccess = (event as OnReportedEvent).isSuccess;
        if (isSuccess == true) {
          Util.showIconTextToast(context, Icons.mail, "回報成功\n感謝您的回饋");
        } else {
          Util.showIconTextToast(context, Icons.sms_failed, "回報失敗\n請稍候再試");
        }
        Navigator.pop(context, isSuccess);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Provider<ReportBloc>(
      builder: (context) {
        var reportBloc = kiwi.Container().resolve<ReportBloc>();
        eventSub = reportBloc.eventStream.listen(_handleEvent);
        return reportBloc;
      },
      dispose: (_, bloc) {
        eventSub?.cancel();
        bloc.dispose();
      },
      child: WillPopScope(
        onWillPop: () async {
          await _dialogAnimController.reverse();
          return true;
        },
        child: ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _dialogAnimController,
              curve: Curves.fastOutSlowIn,
            ),
          ),
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
                  child: Stack(
                    children: <Widget>[
                      _buildReportShop(context),
                      Positioned.fill(
                        child: Consumer<ReportBloc>(
                          builder: (context, bloc, child) {
                            return LoadingWidget(
                              isLoadingStream: bloc.isLoading,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportShop(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              "店家資料勘誤",
              style: Theme.of(context).textTheme.headline6,
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
                    "店家名稱",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  TextField(
                    controller: _shopNameController,
                    readOnly: true,
                    enabled: false,
                    enableInteractiveSelection: false,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "門市據點",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  TextField(
                    controller: _branchNameController,
                    readOnly: true,
                    enabled: false,
                    enableInteractiveSelection: false,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "縣市",
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            TextField(
                              controller: _cityController,
                              readOnly: true,
                              enabled: false,
                              enableInteractiveSelection: false,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "地區",
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            TextField(
                              controller: _districtController,
                              readOnly: true,
                              enabled: false,
                              enableInteractiveSelection: false,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    "回報項目",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 4),
                  ValueListenableBuilder(
                    valueListenable: _reportItemNotifier,
                    builder: (context, reportItem, child) {
                      return Container(
                        height: 50,
                        decoration: ShapeDecoration(
                          color: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: DropdownButtonFormField<_ShopReportItem>(
                          value: reportItem,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 8),
                            border: InputBorder.none,
                          ),
                          hint: Text(
                            "選擇回報項目",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(color: Colors.grey),
                          ),
                          validator: (value) => value == null ? "必填" : null,
                          items: [
                            DropdownMenuItem(
                              value: _ShopReportItem.location,
                              child: Text(
                                "位置不準確",
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ),
                            DropdownMenuItem(
                              value: _ShopReportItem.data,
                              child: Text(
                                "店家資料錯誤",
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              _reportItemNotifier?.value = value,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4),
                  ValueListenableBuilder<_ShopReportItem>(
                    valueListenable: _reportItemNotifier,
                    builder: (context, item, child) {
                      String desc;
                      if (item == _ShopReportItem.location) {
                        desc = "該地點未看見此店家或距離誤差過大";
                      } else if (item == _ShopReportItem.data) {
                        desc = "資料不正確或該門市已不存在";
                      } else {
                        desc = "";
                      }
                      return Visibility(
                        visible: item != null,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 2),
                            Text(
                              desc,
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
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
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<ReportBloc>(
      builder: (context, reportBloc, child) {
        return ValueListenableBuilder<_ShopReportItem>(
          valueListenable: _reportItemNotifier,
          builder: (context, reportItem, child) {
            return Container(
              width: double.infinity,
              child: RaisedButton(
                  disabledTextColor: Colors.grey.shade700,
                  disabledColor: Colors.grey.shade300,
                  shape: StadiumBorder(),
                  elevation: 8,
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  child: Text("回報"),
                  onPressed: reportItem == null
                      ? null
                      : () => reportBloc?.reportShop(widget._shop.docId,
                          reportItem.toString()?.split(".")?.last)),
            );
          },
        );
      },
    );
  }
}

enum ReportType { bugReport, wish, opinion }
enum _BugSeverity { light, normal, severe }
enum _ShopReportItem { location, data }
