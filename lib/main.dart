import 'dart:async';

import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/app_event.dart';
import 'package:boba_explorer/di/injector.dart';
import 'package:boba_explorer/ui/boba_map_page/boba_map.dart';
import 'package:boba_explorer/ui/boba_map_page/boba_map_bloc.dart';
import 'package:boba_explorer/ui/event.dart';
import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:boba_explorer/ui/report/report_dialog.dart';
import 'package:boba_explorer/ui/web_view/web_view_page.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';

void main() {
  inject();
  runApp(
    MultiProvider(
      providers: [
        Provider<AppBloc>(
          builder: (_) => kiwi.Container().resolve<AppBloc>(),
          dispose: (_, appBloc) => appBloc.dispose(),
        ),
        Provider<LoginBloc>(
          builder: (_) => kiwi.Container().resolve<LoginBloc>(),
          dispose: (_, loginBloc) => loginBloc.dispose(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Event> eventSub;
  AppBloc appBloc;

  @override
  void initState() {
    super.initState();
    appBloc = Provider.of<AppBloc>(context, listen: false);
    eventSub = appBloc.eventStream.listen(_handleEvent);
    appBloc.checkAppVersion();
  }

  void _handleEvent(Event event) {
    final navigatorContext = navigatorKey?.currentState?.overlay?.context;
    switch (event.runtimeType) {
      case UpdateAppEvent:
        var updateAppEvent = event as UpdateAppEvent;
        showDialog<bool>(
          context: navigatorContext,
          barrierDismissible: !updateAppEvent.isForceUpdate,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => !updateAppEvent.isForceUpdate,
              child: _AppUpdateDialog(updateAppEvent.isForceUpdate,
                  updateAppEvent.requiredAppVersion),
            );
          },
        ).then((willingToUpdate) {
          if (!willingToUpdate) {
            appBloc?.checkRatingReminder();
          }
        });
        break;
      case RemindRatingEvent:
        _showRemindRatingDialog(navigatorContext);
        break;
    }
  }

  @override
  void dispose() {
    eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: _routeGenerator,
        navigatorObservers: [BotToastNavigatorObserver()],
      ),
    );
  }

  void _showRemindRatingDialog(BuildContext navigatorContext) {
    showDialog(
      context: navigatorContext,
      builder: (context) {
        var buttonTextStyle = Theme.of(context).textTheme.subtitle1;
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
                appBloc?.answerRatingReminder(true);
                Navigator.pop(context);
                LaunchReview.launch();
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
                  appBloc?.answerRatingReminder(isReportSent);
                });
              },
              child: Text('我有些建議.. 💬', style: buttonTextStyle),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                appBloc?.answerRatingReminder(false);
              },
              child: Text('稍後再說 🤔', style: buttonTextStyle),
            )
          ],
        );
      },
    );
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
              builder: (_) => kiwi.Container().resolve<BobaMapBloc>(),
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
      if (_forceUpdate)
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text("稍後"),
        ),
      FlatButton(
        onPressed: () {
          LaunchReview.launch(writeReview: false);
          if (!_forceUpdate) {
            Navigator.pop(context, true);
          }
        },
        child: Text("前往更新"),
      )
    ];
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      title: Text("版本更新"),
      content: Text("新版本 $_requiredVersion 已經可以下載囉 :)"),
      actions: options,
    );
  }
}
