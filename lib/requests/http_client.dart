import 'package:dio/dio.dart';
import 'package:flutter_dmzj/app/app_error.dart';
import 'package:flutter_dmzj/requests/api.dart';
import 'package:flutter_dmzj/requests/custom_interceptor.dart';

class HttpClient {
  static HttpClient? _httpUtil;

  static HttpClient get instance {
    _httpUtil ??= HttpClient();
    return _httpUtil!;
  }

  late Dio dio;
  HttpClient() {
    dio = Dio();
    dio.interceptors.add(CustomInterceptor());
  }

  /// Get请求，返回Map
  /// * [path] 请求链接
  /// * [queryParameters] 请求参数
  /// * [cancel] 任务取消Token
  /// * [needLogin] 是否需要登录
  /// * [withDefaultParameter] 是否需要带上一些默认参数
  Future<dynamic> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    String baseUrl = Api.BASE_URL_V3,
    CancelToken? cancel,
    bool withDefaultParameter = true,
    bool needLogin = false,
  }) async {
    Map<String, dynamic> header = {};
    queryParameters ??= <String, dynamic>{};
    var query = Api.getDefaultParameter(withUid: needLogin);
    if (withDefaultParameter) {
      queryParameters.addAll(query);
    }

    try {
      var result = await dio.get(
        baseUrl + path,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.json,
          headers: header,
        ),
        cancelToken: cancel,
      );
      return result.data;
    } on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        return throw AppError("请求失败：${e.response?.statusCode ?? -1}");
      }
      throw AppError("请求失败,请检查网络");
    }
  }

  /// Post请求，返回Map
  /// * [path] 请求链接
  /// * [data] 发送数据
  /// * [queryParameters] 请求参数
  /// * [cancel] 任务取消Token
  Future<dynamic> postJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    String baseUrl = Api.BASE_URL_V3,
    CancelToken? cancel,
  }) async {
    Map<String, dynamic> header = {};
    queryParameters ??= {};
    try {
      var result = await dio.post(
        baseUrl + path,
        queryParameters: queryParameters,
        data: data,
        options: Options(
          responseType: ResponseType.json,
          headers: header,
        ),
        cancelToken: cancel,
      );
      return result.data;
    } on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        return throw AppError("请求失败:状态码：${e.response?.statusCode ?? -1}");
      }
      throw AppError("请求失败,请检查网络");
    }
  }
}
