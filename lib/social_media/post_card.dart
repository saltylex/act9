import 'package:flutter/material.dart';

import 'post.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin {
  final _commentController = TextEditingController();
  final List<String> _comments = [];
  bool _isLiked = false;

  // Keep reactions and comment drafts even when a card scrolls off screen.
  @override
  bool get wantKeepAlive => true;

  void likePost() => setState(() => _isLiked = !_isLiked);

  void addComment() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;
    setState(() => _comments.add(comment));
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final username = widget.post.username.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(
                username.isEmpty
                    ? '?'
                    : username.characters.first.toUpperCase(),
              ),
            ),
            title: Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Student Feed'),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.post.caption,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Image.network(
            widget.post.imageUrl,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            semanticLabel: 'Image posted by $username',
            errorBuilder: (_, error, stackTrace) => const SizedBox(
              height: 220,
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image, size: 56, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Image unavailable'),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: likePost,
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : null,
                ),
                label: Text(_isLiked ? 'Liked' : 'Like'),
              ),
              Text('${_comments.length} Comments'),
            ],
          ),
          for (final comment in _comments)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(comment),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => addComment(),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      labelText: 'Comment',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addComment,
                  icon: const Icon(Icons.send),
                  tooltip: 'Send comment',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
