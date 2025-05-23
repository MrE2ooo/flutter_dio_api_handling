// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:task4/features/posts/domain/repositories/post_repository_impl.dart';
import 'package:task4/features/presentation/pages/post_page.dart';

import 'core/constants/api_constants.dart';
import 'features/posts/data/datasources/post_remote_data_source.dart';

import 'features/posts/domain/repositories/post_repository.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // 1. Provide Dio instance
        RepositoryProvider<Dio>(
          create: (context) => Dio(BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          )),
        ),
        
        // 2. Provide PostRemoteDataSource - CORRECT USAGE
        RepositoryProvider<PostRemoteDataSource>(
          create: (context) => PostRemoteDataSource(
            dio: context.read<Dio>(),  // Using named parameter
          ),
        ),
        
        // 3. Provide PostRepository
        RepositoryProvider<PostRepository>(
          create: (context) => PostRepositoryImpl(
            remoteDataSource: context.read<PostRemoteDataSource>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter API Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const PostPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}