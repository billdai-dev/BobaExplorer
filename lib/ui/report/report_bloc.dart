import 'dart:convert';

import 'package:boba_explorer/domain/entity/report.dart';
import 'package:boba_explorer/domain/use_case/report/report_use_case.dart';
import 'package:boba_explorer/ui/base_bloc.dart';
import 'package:boba_explorer/domain/entity/city_data.dart';
import 'package:boba_explorer/data/repository/report/report_repository.dart';
import 'package:boba_explorer/ui/event.dart';
import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart' show rootBundle;

class ReportBloc extends BaseBloc {
  final ReportUseCase _reportUseCase;

  final PublishSubject<bool> _isLoadingController = PublishSubject();

  Stream<bool> get isLoading => _isLoadingController.stream;

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
    _isLoadingController.add(true);
    Report bugReport = Report.bug(desc, severity);
    _reportUseCase
        .execute(bugReport)
        .then((resultStream) => resultStream.first)
        .then((isSuccess) => eventSink.add(Event.onReported(isSuccess)))
        .whenComplete(() => _isLoadingController.add(false));
  }

  void reportRequest(String desc, {String city, String district}) {
    _isLoadingController.add(true);
    Report requestReport = Report.request(desc, city: city, district: district);
    _reportUseCase
        .execute(requestReport)
        .then((resultStream) => resultStream.first)
        .then((isSuccess) => eventSink.add(Event.onReported(isSuccess)))
        .whenComplete(() => _isLoadingController.add(false));
  }

  void reportOpinion(String desc) {
    _isLoadingController.add(true);
    Report opinionReport = Report.opinion(desc);
    _reportUseCase
        .execute(opinionReport)
        .then((resultStream) => resultStream.first)
        .then((isSuccess) => eventSink.add(Event.onReported(isSuccess)))
        .whenComplete(() => _isLoadingController.add(false));
  }

  void reportShop(String shopId, String reason) {
    _isLoadingController.add(true);
    Report shopReport = Report.shop(shopId, reason);
    _reportUseCase
        .execute(shopReport)
        .then((resultStream) => resultStream.first)
        .then((isSuccess) => eventSink.add(Event.onReported(isSuccess)))
        .whenComplete(() => _isLoadingController.add(false));
  }

  @override
  void dispose() {
    super.dispose();
    _isLoadingController?.close();
    _currentUser?.close();
    _citiesController?.close();
  }
}
