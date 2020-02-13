import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/data/repository/favorite/favorite_repository.dart';
import 'package:boba_explorer/data/repository/auth/auth_repo.dart';
import 'package:boba_explorer/data/repository/tea_shop/tea_shop_repo.dart';
import 'package:boba_explorer/ui/boba_map_page/boba_map.dart';
import 'package:boba_explorer/ui/boba_map_page/boba_map_bloc.dart';
import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:boba_explorer/ui/report/report_dialog.dart';
import 'package:boba_explorer/ui/web_view/web_view_page.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          Provider<AppBloc>(
            builder: (_) => AppBloc(),
            dispose: (_, appBloc) => appBloc.dispose(),
          ),
          Provider<LoginBloc>(
            builder: (_) => LoginBloc(AuthRepository(), FavoriteRepository()),
            dispose: (_, loginBloc) => loginBloc.dispose(),
          ),
        ],
        child: MyApp(),
      ),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _appVersionChecked = false;
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: _routeGenerator,
        navigatorObservers: [BotToastNavigatorObserver()],
        builder: (context, child) {
          if (!_appVersionChecked) {
            _checkAppVersion(context).then((shouldUpdateApp) {
              if (shouldUpdateApp == null) {
                return _initRateMyApp();
              }
              return null;
            });
          }
          return child;
        },
      ),
    );
  }

  Future<bool> _checkAppVersion(BuildContext context) async {
    if (_appVersionChecked) {
      return null;
    }
    _appVersionChecked = true;
    AppBloc appBloc = Provider.of<AppBloc>(context, listen: false);
    return appBloc.appVersion.first.then((event) {
      if (!event.shouldUpdate) {
        return null;
      }
      final navigatorContext = navigatorKey?.currentState?.overlay?.context;
      return showDialog<bool>(
        context: navigatorContext,
        barrierDismissible: !event.forceUpdate,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => !event.forceUpdate,
            child: _AppUpdateDialog(event.forceUpdate, event.requiredVersion),
          );
        },
      );
    });
  }

  void _initRateMyApp() {
    RateMyApp rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 0,
      minLaunches: 5,
      remindDays: 1,
      remindLaunches: 5,
    );
    rateMyApp.init().then((_) {
      if (!rateMyApp.shouldOpenDialog) {
        return null;
      }
      final navigatorContext = navigatorKey?.currentState?.overlay?.context;
      return showDialog(
        context: navigatorContext,
        builder: (context) {
          var buttonTextStyle = Theme.of(context).textTheme.subhead;
          return SimpleDialog(
            titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            contentPadding: const EdgeInsets.only(top: 8, bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text('願意幫找茶評個分嗎 (✪ω✪)'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  rateMyApp.doNotOpenAgain = true;
                  rateMyApp.save().then((_) {
                    Navigator.pop(context);
                    LaunchReview.launch();
                  });
                },
                child: Text('好的 🤩🤩', style: buttonTextStyle),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  return showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        ReportDialog(reportType: ReportType.opinion),
                  ).then((isReportSent) {
                    if (isReportSent == true) {
                      rateMyApp.doNotOpenAgain = true;
                      return rateMyApp.save();
                    } else {
                      rateMyApp.baseLaunchDate = rateMyApp.baseLaunchDate
                          .add(Duration(days: rateMyApp.remindDays));
                      rateMyApp.launches -= rateMyApp.remindLaunches;
                      return rateMyApp
                          .save()
                          .then((v) => Navigator.pop(context));
                    }
                  });
                },
                child: Text('我有些建議.. 💬', style: buttonTextStyle),
              ),
              SimpleDialogOption(
                onPressed: () {
                  rateMyApp.baseLaunchDate = rateMyApp.baseLaunchDate
                      .add(Duration(days: rateMyApp.remindDays));
                  rateMyApp.launches -= rateMyApp.remindLaunches;
                  return rateMyApp.save().then((v) => Navigator.pop(context));
                },
                child: Text('稍後再說囉', style: buttonTextStyle),
              )
            ],
          );
        },
      );
/*
      return rateMyApp.showStarRateDialog(
        context,
        title: '幫找茶評個分 d(`･∀･)b',
        message: '如果你覺得找茶有幫助到你的話，給我們打個分數當作鼓勵吧\n⁽⁽ ◟(∗ ˊωˋ ∗)◞ ⁾⁾',
        onRatingChanged: (stars) {
          return [
            FlatButton(
              child: Text('我評好了 🤩🤩'),
              onPressed: () {
                rateMyApp.doNotOpenAgain = true;
                rateMyApp.save().then((_) => Navigator.pop(context));
              },
            ),
            if (stars < 4)
              FlatButton(
                child: Text('我還有話想說 💬'),
                onPressed: () {
                  rateMyApp.doNotOpenAgain = true;
                  rateMyApp.save().then((_) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return ReportDialog(reportType: ReportType.opinion);
                      },
                    );
                  });
                },
              ),
            FlatButton(
              child: Text('稍後再說'),
              onPressed: () {
                rateMyApp.save().then((_) => Navigator.pop(context));
              },
            ),
            FlatButton(
              child: Text('別再要我打分數啦'),
              onPressed: () {
                rateMyApp.doNotOpenAgain = true;
                rateMyApp.save().then((_) => Navigator.pop(context));
              },
            ),
          ];
        },
        ignoreIOS: false,
        dialogStyle: DialogStyle(
          titleAlign: TextAlign.center,
          messageAlign: TextAlign.center,
          messagePadding: EdgeInsets.only(bottom: 12),
        ),
        starRatingOptions: StarRatingOptions(),
      );
*/
    });
  }

  Route<dynamic> _routeGenerator(RouteSettings routeSetting) {
    String routeName = routeSetting.name;
    Map<String, dynamic> args = routeSetting.arguments is Map<String, dynamic>
        ? routeSetting.arguments as Map<String, dynamic>
        : null;
    String lastRoute = routeName.substring(routeSetting.name.lastIndexOf("/"));
    return MaterialPageRoute(
      builder: (context) {
        switch (lastRoute) {
          case BobaMap.routeName:
            return Provider<BobaMapBloc>(
              builder: (_) => BobaMapBloc(
                  TeaShopRepository(), FavoriteRepository(), AuthRepository()),
              dispose: (_, bloc) => bloc.dispose(),
              child: BobaMap(),
            );
          case WebViewPage.routeName:
            String title = args[WebViewPage.arg_title];
            String url = args[WebViewPage.arg_url];
            return WebViewPage(title, url);
          default:
            return Container(
              alignment: Alignment.center,
              child: Scaffold(
                body: Center(
                  child: Text("Page not found"),
                ),
              ),
            );
        }
      },
      settings: routeSetting,
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
        onPressed: () {
          LaunchReview.launch(writeReview: false);
          if (!_forceUpdate) {
            Navigator.pop(context, true);
          }
        },
        child: Text("Sure"),
      )
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
      actions: options,
    );
  }
}
