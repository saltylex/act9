import 'dart:js_interop';

@JS('window.open')
external JSAny? _openWindow(String url, String target, String features);

void openProfileLink(String url) {
  _openWindow(url, '_blank', 'noopener,noreferrer');
}
