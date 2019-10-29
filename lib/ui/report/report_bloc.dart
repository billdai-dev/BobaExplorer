import 'dart:convert';

import 'package:boba_explorer/data/bloc_base.dart';
import 'package:boba_explorer/data/repo/city_data.dart';
import 'package:boba_explorer/data/repo/report/report_repo.dart';
import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ReportBloc extends BlocBase {
  final ReportRepo _reportRepo;

  final BehaviorSubject<FirebaseUser> _currentUser = BehaviorSubject();

  final BehaviorSubject<List<City>> _citiesController = BehaviorSubject();

  Stream<List<City>> get cities => _citiesController.stream;

  ReportBloc(BuildContext context, LoginBloc loginBloc, this._reportRepo) {
    loginBloc.currentUser.listen(_currentUser.add);

    DefaultAssetBundle.of(context).loadString("assets/city.json").then((json) {
      _citiesController.add(CityData.fromJson(jsonDecode(json)).city);
    });
  }

  Future<bool> reportBug(String desc, int severity) {
    String uid = _currentUser.value?.uid;
    return _reportRepo.reportBug(desc, severity, uid: uid);
  }

  Future<bool> reportRequest(String desc, {String city, String district}) {
    String uid = _currentUser.value?.uid;
    return _reportRepo.reportRequest(desc,
        uid: uid, city: city, district: district);
  }

  Future<bool> reportOpinion(String desc) {
    String uid = _currentUser.value?.uid;
    return _reportRepo.reportOpinion(desc, uid: uid);
  }

  Future<bool> reportShop(String reason, String shopName, String branchName,
      String city, String district) {
    String uid = _currentUser.value?.uid;
    return _reportRepo.reportShop(shopName, branchName, city, district, reason,
        uid: uid);
  }

  @override
  void dispose() {
    _currentUser?.close();
    _citiesController?.close();
  }
}
