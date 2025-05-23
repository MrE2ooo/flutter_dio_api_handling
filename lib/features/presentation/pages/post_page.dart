import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/post_bloc.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: BlocProvider(
        create: (context) => PostBloc(
          postRepository: context.read(),
        )..add(GetPostsEvent()),
        child: const PostView(),
      ),
    );
  }
}

class PostView extends StatelessWidget {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostInitial || state is PostLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PostError) {
          return Center(child: Text(state.message));
        } else if (state is PostLoaded) {
          return ListView.builder(
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return ListTile(
                title: Text(post.title),
                subtitle: Text(post.body),
                leading: Text(post.id.toString()),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}