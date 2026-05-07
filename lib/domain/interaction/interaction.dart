import 'package:flutter/material.dart';
import 'package:http/http.dart' as  http;

import '../../common/localization/l10n.dart';
import '../../common/utilities.dart';
import '../../common/utils/custom_dialog.dart';
import '../../data/local/shared_prefs/shared_prefs_key.dart';
import '../../data/models/base/response_model.dart';
import '../../data/network/http/http_status_code.dart';
import '../../data/network/http/http_connection.dart';
import '../../data/network/api/api.dart';

class Interaction extends HttpConnection<ResponseModel> {

  final String _tag = "Interaction";

  final BuildContext context;
  final String url;
  final Map<String, dynamic>? param;
  final Map<String, String>? header;
  final List<MultipartFileModel>? files;
  final bool showError;

  Interaction({
    required this.context,
    required this.url,
    this.param,
    this.header,
    this.files,
    this.showError = true,
  });

  @override
  // TODO: implement apiUrl
  String get apiUrl => url;

  @override
  // TODO: implement bodyParam
  Map<String, dynamic>? get bodyParam => param;

  @override
  // TODO: implement headerParam
  Map<String, String>? get headerParam => header;

  @override
  // TODO: implement listFile
  List<MultipartFileModel>? get listFile => files;

  @override
  // TODO: implement baseUrl
  String? get baseUrl => API.server;

  @override
  // TODO: implement tokenKey
  String get tokenKey => SharedPrefsKey.token;

  @override
  Future<ResponseModel> handleError(ResponseModel model) async {
    // TODO: implement handleError
    // if (model.errorCode == 401) {
    //   ResponseModel response = await Repository.refreshToken(context, RefreshTokenRequestModel(
    //     refreshToken: Globals.prefs.getString(tokenKey),
    //     brandCode: Globals.prefs.getString(SharedPrefsKey.brand_code),
    //     platform: Globals.prefs.getString(SharedPrefsKey.platform),
    //     deviceToken: await getToken(),
    //     imei: Globals.prefs.getString(SharedPrefsKey.imei),
    //   ));
    //   if(response.success){
    //     LoginResponseModel responseModel = LoginResponseModel.fromJson(response.data ?? <String, dynamic>{});
    //
    //     Globals.prefs.setString(tokenKey, responseModel.accessToken!);
    //
    //     return retry();
    //   }
    //   else{
    //     await CustomDialog.showAlert(
    //         context, LangKey.current.error, LangKey.current.token_expired,
    //         onSubmitted: () async => await setupLogout(context), cancelable: false);
    //   }
    // } else {
    //   if (showError)
    //     await CustomDialog.showAlert(context,
    //         LangKey.current.notification, model.errorDescription ?? "");
    // }

    if (showError)
      await CustomDialog.showAlert(context,
          LangKey.current.notification, model.errorDescription ?? "");
    return model;
  }

  @override
  Future<ResponseModel> handleResponse(http.Response? response) async {
    // TODO: implement handleResponse
    Utilities.customPrint("$_tag Http url: $url");
    Utilities.customPrint("$_tag Http code: ${response!.statusCode}");
    Utilities.customPrint("$_tag Http body: ${response.body}");
    if (HttpStatusCode.success.contains(response.statusCode)) {
      if (response.body == "") {
        return await handleError(getError(LangKey.current.server_error));
      } else {
        try {
          ResponseModel modelResponse =
          ResponseModel.fromJson(Utilities.stringToJson(response.body));
          if (modelResponse.success)
            return modelResponse;
          else
          return await handleError(modelResponse);
        } catch (_) {
          return await handleError(getError(LangKey.current.data_error));
        }
      }
    } else {
      return await handleError(getError(
          LangKey.current.server_error,
          errorCode: response.statusCode));
    }
  }

  @override
  ResponseModel getError(String? error, {int? errorCode}) {
    // TODO: implement getError
    return ResponseModel(errorDescription: error, errorCode: errorCode);
  }
}