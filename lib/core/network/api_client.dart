import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_token_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Cliente HTTP único do app. Nenhuma outra classe deve instanciar `Dio`
/// diretamente — sempre através de [ApiClient], para garantir que
/// autenticação e tratamento de erro central sejam sempre aplicados.
class ApiClient {
  ApiClient({Dio? dio, SecureTokenStorage? tokenStorage})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
            ),
          ) {
    _dio.interceptors.addAll([
      AuthInterceptor(tokenStorage ?? SecureTokenStorage()),
      ErrorInterceptor(),
      if (kDebugMode)
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
    ]);
  }

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _run(() => _dio.get<T>(path, queryParameters: queryParameters));

  Future<Response<T>> post<T>(String path, {Object? data}) =>
      _run(() => _dio.post<T>(path, data: data));

  Future<Response<T>> put<T>(String path, {Object? data}) =>
      _run(() => _dio.put<T>(path, data: data));

  Future<Response<T>> delete<T>(String path, {Object? data}) =>
      _run(() => _dio.delete<T>(path, data: data));

  Future<Response<T>> _run<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (err) {
      final mapped = err.error;
      if (mapped is ApiException) throw mapped;
      throw const ServerException();
    }
  }
}
