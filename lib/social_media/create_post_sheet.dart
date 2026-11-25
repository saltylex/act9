import 'package:flutter/material.dart';

import 'post.dart';

class CreatePostSheet extends StatefulWidget {
  final String username;

  const CreatePostSheet({super.key, required this.username});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _captionController = TextEditingController();
  final _imageController = TextEditingController();
  String? _error;

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }

  void submitPost() {
    final caption = _captionController.text.trim();
    final imageUrl = _imageController.text.trim();
    if (caption.isEmpty || imageUrl.isEmpty) {
      setState(() => _error = 'Complete both fields before submitting!');
      return;
    }
    final uri = Uri.tryParse(imageUrl);
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      setState(() => _error = 'Enter a valid HTTP or HTTPS image URL.');
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(
      Post(username: widget.username, caption: caption, imageUrl: imageUrl),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Post', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Posting as ${widget.username}'),
          const SizedBox(height: 20),
          TextField(
            key: const ValueKey('post-caption'),
            controller: _captionController,
            onChanged: _clearError,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Caption',
              prefixIcon: Icon(Icons.edit),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            key: const ValueKey('post-image'),
            controller: _imageController,
            onChanged: _clearError,
            keyboardType: TextInputType.url,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submitPost(),
            decoration: const InputDecoration(
              labelText: 'Image URL',
              prefixIcon: Icon(Icons.image),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              key: const ValueKey('post-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            key: const ValueKey('submit-post'),
            onPressed: submitPost,
            child: const Text('Submit Post'),
          ),
        ],
      ),
    ),
  );
}
