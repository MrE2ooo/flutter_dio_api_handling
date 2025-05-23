
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task4/features/posts/domain/entities/post_entity.dart';
import 'package:task4/features/posts/domain/repositories/post_repository.dart';


part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostBloc({required this.postRepository}) : super(PostInitial()) {
    on<GetPostsEvent>(_onGetPosts);
  }

  Future<void> _onGetPosts(
    GetPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    try {
      final posts = await postRepository.getPosts();
      emit(PostLoaded(posts: posts));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }
}