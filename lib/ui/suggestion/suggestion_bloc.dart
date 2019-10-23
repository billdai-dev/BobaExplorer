import 'dart:convert';

import 'package:boba_explorer/data/bloc_base.dart';
import 'package:boba_explorer/data/repo/city_data.dart';
import 'package:boba_explorer/ui/login/login_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SuggestionBloc extends BlocBase {
  final BehaviorSubject<FirebaseUser> _currentUser = BehaviorSubject();

  final BehaviorSubject<List<City>> _citiesController = BehaviorSubject();

  Stream<List<City>> get cities => _citiesController.stream;

  SuggestionBloc(BuildContext context, LoginBloc loginBloc) {
    loginBloc.currentUser.listen(_currentUser.add);

    DefaultAssetBundle.of(context).loadString("assets/city.json").then((json) {
      _citiesController.add(CityData.fromJson(jsonDecode(json)).city);
    });
  }

  @override
  void dispose() {
    _currentUser?.close();
    _citiesController?.close();
  }
}
