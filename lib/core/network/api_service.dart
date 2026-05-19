import 'package:dio/dio.dart';
import 'package:huungry/core/network/api_exceptions.dart';
import 'package:huungry/core/network/dio_client.dart';

class ApiService {
  final DioClient _dioClient = DioClient();

  /// CRUD METHODS

  /// get
  Future<dynamic> get(String endPoint , {dynamic param}) async {
    try {
      final response = await _dioClient.dio.get(endPoint, queryParameters: param);
      return response.data;
    } on DioException catch (e) {
      return ApiExceptions.handleError(e);
    }
  }

  /// post
  Future<dynamic> post(String endPoint, dynamic body) async {
    try {
      final response = await _dioClient.dio.post(endPoint, data: body);
      return response.data;
    } on DioException catch (e) {
      return ApiExceptions.handleError(e);
    }
  }

  /// put || update
  Future<dynamic> put(String endPoint, dynamic body) async {
    try {
      final response = await _dioClient.dio.put(endPoint, data: body);
      return response.data;
    } on DioException catch (e) {
      return ApiExceptions.handleError(e);
    }
  }

  /// delete
  Future<dynamic> delete(String endPoint, dynamic body, {dynamic params}) async {
    try {
      final response = await _dioClient.dio.delete(endPoint, data: body , queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      return ApiExceptions.handleError(e);
    }
  }
}
