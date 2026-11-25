import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'profile_link_stub.dart'
    if (dart.library.js_interop) 'profile_link_web.dart'
    as platform;

void showProfileLink(BuildContext context, String account, String url) {
  // Call synchronously from the tap so browsers can open the new tab.
  // Copy link remains available on other platforms or if popups are blocked.
  platform.openProfileLink(url);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Selected account: $account'),
        action: SnackBarAction(
          label: 'Copy link',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Profile link copied.')),
              );
          },
        ),
      ),
    );
}
