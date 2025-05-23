import 'package:task4/features/posts/data/datasources/post_remote_data_source.dart';

import '../../domain/repositories/post_repository.dart';

import '../../domain/entities/post_entity.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostEntity>> getPosts() async {
    final posts = await remoteDataSource.getPosts();
    return posts.map((post) => post.toEntity()).toList();
  }
}