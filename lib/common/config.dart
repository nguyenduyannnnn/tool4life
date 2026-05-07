import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'assets.dart';
import 'constant.dart';
import 'globals.dart';

class Config {
  static Future<void> getPreferences() async {
    await SharedPreferences.getInstance().then((event) async {
      Globals.prefs = SharedPrefs(event);
      dynamic jsonResult = Utilities.stringToJson(await rootBundle.loadString(Assets.jsonConfig));
      Globals.applicationMode = jsonResult["environment"];
      Globals.config = Config.fromJson(jsonResult[jsonResult["environment"]]);
      if((Globals.config.langDefault ?? "").isNotEmpty){
        Constant.langDefault = Globals.config.langDefault!;
      }
      String lang = Globals.prefs.getString(SharedPrefsKey.language, value: Constant.langDefault);
      Globals.locale = Locale(lang);
    });
    return;
  }

  String? server;
  String? langDefault;
  bool? enableLang;
  String? releaseDate;
  bool? displayPrint;

  Config(
      {this.server,
        this.langDefault,
        this.enableLang,
        this.releaseDate,
        this.displayPrint});

  Config.fromJson(Map<String, dynamic> json) {
    server = json['server'];
    if (!server!.endsWith("/")) {
      server = "$server/";
    }
    langDefault = json['langDefault'];
    enableLang = json['enableLang'] ?? false;
    releaseDate = json['releaseDate'];
    displayPrint = json['displayPrint'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['server'] = this.server;
    data['langDefault'] = this.langDefault;
    data['enableLang'] = this.enableLang;
    data['releaseDate'] = this.releaseDate;
    data['displayPrint'] = this.displayPrint;
    return data;
  }
}
