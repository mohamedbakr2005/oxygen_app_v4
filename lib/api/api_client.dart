import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Oxygen_Mart/api/api_checker.dart';
import 'package:Oxygen_Mart/common/models/error_response.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 40;

  String? token;
  late Map<String, String> _mainHeaders;

  String? _cachedModuleIdRaw;
  int? _cachedModuleIdValue;

  int? _moduleIdFromCachePref(String raw) {
    if (raw != _cachedModuleIdRaw) {
      try {
        _cachedModuleIdValue = ModuleModel.fromJson(jsonDecode(raw)).id;
        _cachedModuleIdRaw = raw;
      } catch (_) {
        return null;
      }
    }
    return _cachedModuleIdValue;
  }

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    if (kDebugMode) {
      print('Token: $token');
    }
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    } catch (_) {}
    int? moduleID;
    if (sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        moduleID = ModuleModel.fromJson(
                jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!))
            .id;
      } catch (_) {}
    }
    updateHeader(
      token,
      addressModel?.zoneIds,
      addressModel?.areaIds,
      sharedPreferences.getString(AppConstants.languageCode),
      moduleID,
      addressModel?.latitude,
      addressModel?.longitude,
      null,
    );
  }

  Map<String, String> updateHeader(
    String? token,
    List<int>? zoneIDs,
    List<int>? operationIds,
    String? languageCode,
    dynamic moduleID,
    String? latitude,
    String? longitude,
    int? zoneId, {
    bool setHeader = true,
    bool fromModule = false,
  }) {
    Map<String, String> header = {};

    final String? effectiveModuleId = (moduleID != null && moduleID != 'null' && moduleID != '') ? moduleID.toString() : null;

    if (effectiveModuleId != null) {
      header[AppConstants.moduleId] = effectiveModuleId;
    } else if (sharedPreferences.getString(AppConstants.cacheModuleId) != null) {
      int? cacheId = _moduleIdFromCachePref(
          sharedPreferences.getString(AppConstants.cacheModuleId)!);
      if (cacheId != null) {
        header[AppConstants.moduleId] = '$cacheId';
      }
    }

    List<int>? activeZoneIDs = zoneIDs;
    String? activeLat = latitude;
    String? activeLng = longitude;
    if (activeZoneIDs == null && sharedPreferences.containsKey(AppConstants.userAddress)) {
      try {
        AddressModel addr = AddressModel.fromJson(
            jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
        activeZoneIDs = addr.zoneIds;
        activeLat ??= addr.latitude;
        activeLng ??= addr.longitude;
      } catch (_) {}
    }

    header.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.zoneId: (zoneId != null && fromModule)
          ? '$zoneId'
          : activeZoneIDs != null
              ? jsonEncode(activeZoneIDs)
              : '',
      AppConstants.localizationKey: languageCode ??
          sharedPreferences.getString(AppConstants.languageCode) ??
          AppConstants.languages[0].languageCode!,
      AppConstants.latitude: activeLat != null ? jsonEncode(activeLat) : '',
      AppConstants.longitude: activeLng != null ? jsonEncode(activeLng) : '',
    });

    if (token != null && token.isNotEmpty) {
      header['Authorization'] = 'Bearer $token';
    }

    String? guestId = sharedPreferences.getString(AppConstants.guestId);
    if (guestId != null && guestId.isNotEmpty) {
      header[AppConstants.guestId] = guestId;
      header['guest-id'] = guestId;
    }

    if (setHeader) {
      _mainHeaders = header;
    }
    return header;
  }

  Map<String, String> getHeader() => _mainHeaders;

  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool handleError = true,
    bool moduleScoped = false,
    bool rawBody = false,
  }) async {
    try {
      final Map<String, String> requestHeaders = headers ?? _mainHeaders;
      final String? requestModuleId =
          moduleScoped ? requestHeaders[AppConstants.moduleId] : null;

      if (kDebugMode) {
        print(
            '[API CALL] $uri | Module: ${requestHeaders[AppConstants.moduleId]} | Zone: ${requestHeaders[AppConstants.zoneId]} | Auth: ${requestHeaders['Authorization'] != null}');
      }

      http.Response response = await http
          .get(
            Uri.parse(appBaseUrl + uri),
            headers: requestHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));

      if (moduleScoped && requestModuleId != _mainHeaders[AppConstants.moduleId]) {
        if (kDebugMode) {
          print(
              '[API DROP] Stale module response dropped for $uri (requested: $requestModuleId, current: ${_mainHeaders[AppConstants.moduleId]})');
        }
        return const Response(statusCode: 499, statusText: 'stale module response');
      }

      return handleResponse(response, uri, handleError, rawBody: rawBody);
    } catch (e) {
      if (kDebugMode) {
        print('------------${e.toString()}');
      }
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers,
      int? timeout,
      bool handleError = true}) async {
    try {
      final Map<String, String> requestHeaders = headers != null
          ? <String, String>{..._mainHeaders, ...headers}
          : _mainHeaders;
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $requestHeaders');
        print('====> API Body: $body');
      }
      http.Response response = await http
          .post(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: requestHeaders,
          )
          .timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(
      String uri, Map<String, String> body, List<MultipartBody> multipartBody,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
        print('====> API Body: $body with ${multipartBody.length} picture');
      }
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(appBaseUrl + uri));
      final Map<String, String> multipartHeaders = Map<String, String>.from(headers ?? _mainHeaders);
      multipartHeaders.removeWhere((key, value) => key.toLowerCase() == 'content-type');
      request.headers.addAll(multipartHeaders);
      for (MultipartBody multipart in multipartBody) {
        if (multipart.file != null) {
          Uint8List list = await multipart.file!.readAsBytes();
          request.files.add(http.MultipartFile(
            multipart.key,
            multipart.file!.readAsBytes().asStream(),
            list.length,
            filename: '${DateTime.now().toString()}.png',
          ));
        }
      }
      request.fields.addAll(body);
      http.Response response =
          await http.Response.fromStream(await request.send());
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers, bool handleError = true}) async {
    try {
      final Map<String, String> requestHeaders = headers != null
          ? <String, String>{..._mainHeaders, ...headers}
          : _mainHeaders;
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $requestHeaders');
        print('====> API Body: $body');
      }
      http.Response response = await http
          .put(
            Uri.parse(appBaseUrl + uri),
            body: jsonEncode(body),
            headers: requestHeaders,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri,
      {dynamic body, Map<String, String>? headers, bool handleError = true}) async {
    try {
      final Map<String, String> requestHeaders = headers != null
          ? <String, String>{..._mainHeaders, ...headers}
          : _mainHeaders;
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $requestHeaders');
      }
      http.Response response = await http
          .delete(
            Uri.parse(appBaseUrl + uri),
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(
      http.Response response, String uri, bool handleError, {bool rawBody = false}) {
    final String bodyText = response.body;
    dynamic body;
    final bool skipDecode = rawBody && isSuccessCode(response.statusCode);
    if (!skipDecode) {
      try {
        body = jsonDecode(bodyText);
      } catch (_) {}
    }
    final String? envelopeMessage = envelopeMessageOf(body, response.statusCode);
    body = unwrapEnvelope(body, response.statusCode);

    Response response0 = Response(
      body: body ?? bodyText,
      bodyString: bodyText,
      request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: envelopeMessage ?? response.reasonPhrase,
    );
    if (!isSuccessCode(response0.statusCode) &&
        response0.body != null &&
        response0.body is! String) {
      final String? envelopeError = envelopeErrorMessageOf(response0.body);
      if (envelopeError != null) {
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: envelopeError,
        );
      } else if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: errorResponse.errors![0].message);
      } else if (response0.body.toString().startsWith('{response_code: zone_404, message:')) {
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: response0.body['message']);
      } else if(response0.body.toString().startsWith('{response_code: route_404, message:')) {
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: response0.body['message']);
      } else if(response0.body.toString().startsWith('{response_code: incomplete_ride_403, message:')) {
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: response0.body['message']);
      } else if(response0.body.toString().startsWith('{errors: [{code: interest, message:')) {
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: response0.body['message']);
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
            statusCode: response0.statusCode,
            body: response0.body,
            statusText: response0.body['message']);
      }
    } else if (!isSuccessCode(response0.statusCode) && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }
    if (kDebugMode) {
      print('====> API Response: [${response0.statusCode}] $uri');
      if (!ResponsiveHelper.isWeb() || response.statusCode != 500) {
        print('${response0.body}');
      }
    }
    if (handleError) {
      if (isSuccessCode(response0.statusCode)) {
        return response0;
      } else {
        ApiChecker.checkApi(response0);
        return const Response();
      }
    } else {
      return response0;
    }
  }

  static bool isSuccessCode(int? statusCode) =>
      statusCode != null && statusCode >= 200 && statusCode < 300;

  static dynamic unwrapEnvelope(dynamic body, int? statusCode) {
    if (!isSuccessCode(statusCode) || body is! Map) return body;
    if (!body.containsKey('identical_code') || body['content'] == null) return body;
    return body['content'];
  }

  static String? envelopeMessageOf(dynamic body, int? statusCode) {
    if (!isSuccessCode(statusCode) || body is! Map) return null;
    if (!body.containsKey('identical_code') || body['content'] == null) return null;
    final dynamic message = body['message'];
    return message is String ? message : null;
  }

  static String? envelopeErrorMessageOf(dynamic body) {
    if (body is! Map || !body.containsKey('identical_code')) return null;

    final dynamic errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final dynamic first = errors.first;
      if (first is Map && first['message'] is String && (first['message'] as String).isNotEmpty) {
        return first['message'] as String;
      }
    } else if (errors is Map && errors.isNotEmpty) {
      final dynamic first = errors.values.first;
      if (first is List) {
        if (first.isNotEmpty) return first.first?.toString();
      } else if (first != null) {
        return first.toString();
      }
    }

    final dynamic message = body['message'];
    if (message is String && message.isNotEmpty) return message;
    return null;
  }
}

class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}
