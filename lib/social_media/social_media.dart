import 'package:flutter/material.dart';

import '../social_media_page.dart';
import 'create_post_sheet.dart';
import 'post.dart';
import 'post_card.dart';

class SocialMediaPage extends StatefulWidget {
  final String username;

  const SocialMediaPage({super.key, required this.username});

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage> {
  final _scrollController = ScrollController();
  final List<Post> posts = [
    const Post(
      username: 'JohnDoe',
      caption: 'Enjoying the sunny weather!',
      imageUrl: 'https://picsum.photos/id/20/600/400',
    ),
    const Post(
      username: 'JaneSmith',
      caption: 'Just finished a great book!',
      imageUrl: 'https://picsum.photos/id/24/600/400',
    ),
  ];

  Future<void> openCreatePostSheet() async {
    FocusScope.of(context).unfocus();
    final newPost = await showModalBottomSheet<Post>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CreatePostSheet(username: widget.username),
    );
    if (!mounted || newPost == null) return;
    setState(() => posts.insert(0, newPost));
    // A post created while browsing lower in the feed should still be visible.
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Social Media'),
      actions: [
        IconButton(
          tooltip: 'My social links',
          icon: const Icon(Icons.alternate_email),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SocialAccountsPage()),
          ),
        ),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: posts.isEmpty
            ? const Center(child: Text('No posts yet. Create one!'))
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: posts.length,
                // Stable keys plus this lookup retain card state after insertion.
                findChildIndexCallback: (key) {
                  final index = posts.indexWhere(
                    (post) => ObjectKey(post) == key,
                  );
                  return index < 0 ? null : index;
                },
                itemBuilder: (_, index) =>
                    PostCard(key: ObjectKey(posts[index]), post: posts[index]),
              ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      tooltip: 'Create Post',
      onPressed: openCreatePostSheet,
      child: const Icon(Icons.add),
    ),
  );
}
