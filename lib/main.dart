import 'dart:async';

import 'package:boba_explorer/app_bloc.dart';
import 'package:boba_explorer/ui/boba_map_page/boba_map.dart';
import 'package:boba_explorer/ui/boba_map_page/boba_map_bloc.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      Provider<AppBloc>(
        builder: (_) => AppBloc(),
        dispose: (_, appBloc) => appBloc.dispose(),
        child: MaterialApp(
          home: MyApp(),
        ),
      ),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription _checkVersionSub;
  bool _appVersionChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_appVersionChecked) {
      AppBloc appBloc = Provider.of<AppBloc>(context, listen: false);
      if (_checkVersionSub != null) {
        return;
      }
      _checkVersionSub = appBloc.appVersion.listen((event) {
        if (!event.shouldUpdate) {
          return;
        }
        _appVersionChecked = true;
        showDialog<bool>(
                context: context,
                barrierDismissible: !event.forceUpdate,
                builder: (context) =>
                    _AppUpdateDialog(event.forceUpdate, event.requiredVersion))
            .then((agreeUpdate) {
          if (agreeUpdate == null || !agreeUpdate) {
            return;
          }
          LaunchReview.launch(writeReview: false);
        });
      });
    }
  }

  @override
  void dispose() {
    _checkVersionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<BobaMapBloc>(
      builder: (_) => BobaMapBloc(),
      dispose: (_, bloc) => bloc.dispose(),
      child: BobaMap(),
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
          onPressed: () => Navigator.of(context).pop(true), child: Text("Sure"))
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
        actions: options);
  }
}
