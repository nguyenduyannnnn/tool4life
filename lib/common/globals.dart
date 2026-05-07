import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:changmeeting/main.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/bloc/dashboard_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../data/local/shared_prefs/shared_prefs.dart';
import '../data/models/base/country_model.dart';
import '../data/models/base/password_validation_model.dart';
import '../data/models/response/login_response_model.dart';
import 'config.dart';

class Globals {
  static late SharedPrefs prefs;
  static late Config config;
  static late Locale locale;
  static late GlobalKey<MyAppState> myApp;
  static late String applicationMode;
  static http.Client client = http.Client();

  static LoginResponseModel? model;
  static bool isLoggedIn = false;

  static late List<CountryModel> countryModels;
  static final streamCountryModel = BehaviorSubject<CountryModel>();

  static late List<PasswordValidationModel> passwordValidationModels;

  static DashboardBloc? bloc;
}
