import 'dart:convert';

import 'package:boba_explorer/domain/entity/city_data.dart';
import 'package:boba_explorer/domain/entity/report.dart';
import 'package:boba_explorer/domain/use_case/report/report_use_case.dart';
import 'package:boba_explorer/ui/base_bloc.dart';
import 'package:boba_explorer/ui/event.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rxdart/rxdart.dart';

class ReportBloc extends BaseBloc {
  final ReportUseCase _reportUseCase;

  final BehaviorSubject<List<City>> _citiesController = BehaviorSubject();

  Stream<List<City>> get cities => _citiesController.stream;

  ReportBloc(this._reportUseCase) {
    rootBundle
        .loadStructuredData("assets/city.json",
            (json) async => CityData.fromJson(jsonDecode(json)).city)
        .then(_citiesController.add);
    /*DefaultAssetBundle.of(context).loadString("assets/city.json").then((json) {
      _citiesController.add(CityData.fromJson(jsonDecode(json)).city);
    });*/
  }

  void reportBug(String desc, int severity) {
    eventSink.add(Event.changeLoading(true));
    Report bugReport = Report.bug(desc, severity);
    _reportUseCase
        .execute(bugReport)
        .then((resultStream) => resultStream.first)
        .then((isSuccess) => eventSink.add(Event.onReported(isSuccess)))
        .whenComplete(() => eventSink.add(Event.changeLoading(false)));
  }

  void reportRequest(String desc, {String city, String district}) {
    eventSink.add(Event.changeLoading(true));
    Report requestReport = Report.request(desc, city: city, district: district);
    _reportUseCase
        .execute(requestReport)
        .then((resultStream) => resultStream.first)
        .then((isSuccess) => eventSink.add(Event.onReported(isSuccess)))
        .whenComplete(() => eventSink.add(Event.changeLoading(false)));
  }

  void reportOpinion(String desc) {
    eventSink.add(Event.changeLoading(true));
    Report opinionReport = Report.opinion(desc);
    _reportUseCase
        .execute(opinionReport)
        .then((resultStream) => resultStream.first)
        .then((isSuccess) => eventSink.add(Event.onReported(isSuccess)))
        .whenComplete(() => eventSink.add(Event.changeLoading(false)));
  }

  void reportShop(String shopId, String reason) {
    eventSink.add(Event.changeLoading(true));
    Report shopReport = Report.shop(shopId, reason);
    _reportUseCase
        .execute(shopReport)
        .then((resultStream) => resultStream.first)
        .then((isSuccess) => eventSink.add(Event.onReported(isSuccess)))
        .whenComplete(() => eventSink.add(Event.changeLoading(false)));
  }

  @override
  void dispose() {
    super.dispose();
    _citiesController?.close();
  }
}
