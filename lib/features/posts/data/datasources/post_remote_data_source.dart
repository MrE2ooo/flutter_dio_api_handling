import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/post_model.dart';

class PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSource({required this.dio});

  Future<List<PostModel>> getPosts() async {
    try {
      final response = await dio.get(
        ApiConstants.postsEndpoint,
        queryParameters: {'_limit': 10},
        options: Options(
          validateStatus: (status) => status! < 500, // Consider status codes < 500 as valid
        ),
      );

      switch (response.statusCode) {
        case 200: // OK
          return (response.data as List)
              .map((post) => PostModel.fromJson(post))
              .toList();
        case 204: // No Content
          return []; // Return empty list for no content
        case 400: // Bad Request
          throw BadRequestException(response.data.toString());
        case 401: // Unauthorized
          throw UnauthorizedException('Authentication required');
        case 403: // Forbidden
          throw ForbiddenException('Access denied');
        case 404: // Not Found
          throw NotFoundException('Posts not found');
        case 429: // Too Many Requests
          throw TooManyRequestsException('Rate limit exceeded');
        case 500: // Internal Server Error
          throw ServerException('Internal server error');
        default:
          throw ApiException(
            'Received invalid status code: ${response.statusCode}',
            response.statusCode,
          );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw TimeoutException('Request timeout');
        case DioExceptionType.connectionError:
          throw NoInternetException('No internet connection');
        case DioExceptionType.badResponse:
          // Already handled by status code above
          rethrow;
        case DioExceptionType.cancel:
          throw RequestCancelledException('Request cancelled');
        case DioExceptionType.unknown:
          if (e.error is SocketException) {
            throw NoInternetException('Network unavailable');
          }
          throw ApiException('Unknown network error: ${e.message}', null);
        case DioExceptionType.badCertificate:
          throw ApiException('Bad certificate: ${e.message}', null);
      }
    } catch (e) {
      // Handle all other errors
      throw ApiException('Failed to load posts: $e', null);
    }
  }
}

// Custom exception classes
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message, 400);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

class TooManyRequestsException extends ApiException {
  TooManyRequestsException(String message) : super(message, 429);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message, 500);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message, null);
}

class NoInternetException extends ApiException {
  NoInternetException(String message) : super(message, null);
}

class RequestCancelledException extends ApiException {
  RequestCancelledException(String message) : super(message, null);
}