import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:changmeeting/common/constant.dart';
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/localization/l10n.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:changmeeting/data/network/connectivity_checker.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import '../network_connectivity.dart';

abstract class HttpConnection<T> {
  final String _typeApplication = "application/json";
  final String _typeMultipart = "multipart/form-data";
  final String _typeUrlencoded = "application/x-www-form-urlencoded";
  final String _tag = "HttpConnection";
  final int _timeOut = 120;
  ApiConnectionMethod? _method;
  String? _fullURL;
  late bool _isJson;

  String get apiUrl;
  String? get baseUrl;
  Map<String, dynamic>? get bodyParam;
  Map<String, String>? get headerParam;
  List<MultipartFileModel>? get listFile;
  String get tokenKey;

  Future<Map<String, String>> _headers(Map<String, String>? content) async {
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: listFile == null
          ? "$_typeApplication; charset=utf-8"
          : _typeMultipart,
      HttpHeaders.acceptCharsetHeader: "utf-8",
      "lang": Globals.prefs
          .getString(SharedPrefsKey.language, value: Constant.langDefault)
    };

    String token = Globals.prefs.getString(tokenKey);
    if (token != "")
      headers[HttpHeaders.authorizationHeader] = "Bearer " + token;

    if (content != null) {
      content.forEach((key, value) {
        headers[key] = value;
      });
    }

    return headers;
  }

  Future<T> retry() {
    if (_method == ApiConnectionMethod.GET) {
      return get();
    } else if (_method == ApiConnectionMethod.POST) {
      return post();
    } else if (_method == ApiConnectionMethod.DELETE) {
      return delete();
    } else {
      return getGoogleApi();
    }
  }

  Future<T> get() async {
    _method = ApiConnectionMethod.GET;

    String fullUrl = baseUrl! + apiUrl;

    if (bodyParam != null) {
      String body = "?";
      bodyParam!.forEach((key, value) {
        try {
          List<dynamic> values = value;
          values.forEach((data) {
            body = body + key + "=" + data.toString() + "&";
          });
        } catch (ex) {
          body = body + key + "=" + value.toString() + "&";
        }
      });
      body = body.substring(0, body.length - 1);
      fullUrl = fullUrl + body;
    }

    _fullURL = fullUrl;

    return await _handleConnection();
  }

  Future<T> post() async {
    _method = ApiConnectionMethod.POST;

    bool isJson = true;
    if (bodyParam == null)
      isJson = false;
    else {
      if (headerParam != null) {
        isJson = !headerParam!.values.contains(_typeUrlencoded);
      }
    }

    _fullURL = baseUrl! + apiUrl;
    _isJson = isJson;

    return await _handleConnection();
  }

  Future<T> delete() async {
    _method = ApiConnectionMethod.DELETE;

    String fullUrl = baseUrl! + apiUrl;
    _fullURL = fullUrl;
    _isJson = true; // DELETE requests typically use JSON

    return await _handleConnection();
  }

  Future<T> getGoogleApi() async {
    _method = ApiConnectionMethod.GOOGLE;

    _fullURL = apiUrl;

    return _handleConnection();
  }

  Future<T?> _checkConnectivity() async {
    if (!(await NetworkConnectivity.isConnected())) {
      return getError(LangKey.current.connection_error);
    }
    return null;
  }

  Future<T> _handleConnection() async {
    final requestStopwatch = Stopwatch()..start();

    T? data = await _checkConnectivity();
    if (data != null) {
      return await handleError(data);
    }

    // Ping domain check
    if (baseUrl != null) {
      final pingSuccess =
          await ConnectivityChecker.checkServerConnectivity(baseUrl!);
      if (!pingSuccess) {
        Utilities.customPrint(
            "🌐 PING: Domain unreachable, continuing anyway...");
      }
    }

    Map<String, String?> finalHeader = await _headers(headerParam);

    // Enhanced request logging
    final timestamp = DateTime.now().toString().split('.')[0];
    Utilities.customPrint("📡 REQUEST: $_method $_fullURL");
    Utilities.customPrint("📡 HEADERS: $finalHeader");
    Utilities.customPrint("📡 SENT: $timestamp");

    Uri uri = Uri.parse(_fullURL!);

    var response;
    try {
      if (_method == ApiConnectionMethod.GET)
        response = await http
            .get(uri, headers: finalHeader as Map<String, String>?)
            .timeout(Duration(seconds: _timeOut));
      else if (_method == ApiConnectionMethod.POST) {
        if (listFile != null) {
          var request = http.MultipartRequest("POST", uri);
          request.headers.addAll(finalHeader as Map<String, String>);
          if (bodyParam != null && bodyParam!.length > 0) {
            bodyParam!.forEach((key, value) {
              try {
                Map<String, dynamic>? map = value;
                request.fields[key] = json.encode(map);
              } catch (_) {
                request.fields[key] = value.toString();
              }
            });
          }

          for (MultipartFileModel model in listFile!) {
            if (model.file != null) {
              String name = basename(model.file!.path);
              request.files.add(await http.MultipartFile.fromPath(
                  model.name ?? name, model.file!.path,
                  contentType: MediaType.parse(_typeMultipart),
                  filename: name));
            }
          }

          Utilities.customPrint("📡 FIELDS: ${request.fields}");
          request.files.forEach((model) {
            Utilities.customPrint(
                "📡 FILE: ${model.field} - ${model.filename}");
          });

          var result =
              await request.send().timeout(new Duration(seconds: _timeOut));
          response = await http.Response.fromStream(result);
        } else {
          dynamic body = _isJson ? json.encode(bodyParam) : bodyParam;
          if (body != null) {
            Utilities.customPrint("📡 BODY: $body");
          } else {
            Utilities.customPrint("📡 BODY: (empty)");
          }
          response = await Globals.client
              .post(uri,
                  headers: finalHeader as Map<String, String>?, body: body)
              .timeout(Duration(seconds: _timeOut));
        }
      } else if (_method == ApiConnectionMethod.DELETE) {
        response = await Globals.client
            .delete(uri, headers: finalHeader as Map<String, String>?)
            .timeout(Duration(seconds: _timeOut));
      } else
        response = await http.get(uri).timeout(Duration(seconds: _timeOut));
    } on TimeoutException catch (_) {
      requestStopwatch.stop();
      response = getError(LangKey.current.timeout_error);
      Utilities.customPrint(
          "📲 ERROR: Timeout (${requestStopwatch.elapsedMilliseconds}ms)");
      return await handleError(response);
    } on SocketException catch (error) {
      requestStopwatch.stop();
      response = getError("${LangKey.current.server_error}\n${error.message}");
      Utilities.customPrint(
          "📲 ERROR: Socket - ${error.message} (${requestStopwatch.elapsedMilliseconds}ms)");
      return await handleError(response);
    } on ArgumentError catch (error) {
      requestStopwatch.stop();
      response = getError("${LangKey.current.server_error}\n${error.message}");
      Utilities.customPrint(
          "📲 ERROR: Argument - ${error.message} (${requestStopwatch.elapsedMilliseconds}ms)");
      return await handleError(response);
    } catch (error) {
      requestStopwatch.stop();
      response =
          getError("${LangKey.current.server_error}\n${error.toString()}");
      Utilities.customPrint(
          "📲 ERROR: ${error.toString()} (${requestStopwatch.elapsedMilliseconds}ms)");
      return await handleError(response);
    }

    // Enhanced response logging
    requestStopwatch.stop();
    if (response is http.Response) {
      Utilities.customPrint(
          "📲 RESPONSE: ${response.statusCode} ${_getStatusText(response.statusCode)} (${requestStopwatch.elapsedMilliseconds}ms)");
      Utilities.customPrint("📲 BODY: ${utf8.decode(response.bodyBytes)}");
    } else {
      Utilities.customPrint(
          "📲 ERROR: Non-HTTP response (${requestStopwatch.elapsedMilliseconds}ms)");
    }

    return await handleResponse(response);
  }

  String _getStatusText(int statusCode) {
    switch (statusCode) {
      case 200:
        return "OK";
      case 201:
        return "Created";
      case 400:
        return "Bad Request";
      case 401:
        return "Unauthorized";
      case 403:
        return "Forbidden";
      case 404:
        return "Not Found";
      case 500:
        return "Internal Server Error";
      default:
        return "Unknown";
    }
  }

  T getError(String? error, {int? errorCode});

  Future<T> handleError(T model);

  Future<T> handleResponse(http.Response? response);
}

enum ApiConnectionMethod { GET, POST, DELETE, GOOGLE }

class MultipartFileModel {
  File? file;
  String? name;

  MultipartFileModel({this.file, this.name});
}
