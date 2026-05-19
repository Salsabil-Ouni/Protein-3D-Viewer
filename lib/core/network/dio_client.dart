import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

class DioClient {
  late final Dio _dio;
  late final Dio _authDio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.pdbBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _authDio = Dio(BaseOptions(
      baseUrl: ApiConstants.mockAuthBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(_ErrorInterceptor());
    _authDio.interceptors.add(_ErrorInterceptor());
  }

  Dio get pdb => _dio;
  Dio get auth => _authDio;
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      throw const NetworkException('Connection timed out. Check your internet connection.');
    }
    if (err.type == DioExceptionType.connectionError) {
      throw const NetworkException('No internet connection.');
    }
    handler.next(err);
  }
}
