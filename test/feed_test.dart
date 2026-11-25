import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasignasigna_navigation_app/demo_auth.dart';
import 'package:pasignasigna_navigation_app/main.dart';
import 'package:pasignasigna_navigation_app/main_screen.dart';
import 'package:pasignasigna_navigation_app/social_media/post_card.dart';
import 'package:pasignasigna_navigation_app/social_media/create_post_sheet.dart';

import 'widget_test.dart' show field, tap, login, register, tab, logout;

const firstCaption = 'Enjoying the sunny weather!';
Finder card(String caption) =>
    find.ancestor(of: find.text(caption), matching: find.byType(PostCard));
Finder within(Finder post, Finder child) =>
    find.descendant(of: post, matching: child);

Future<void> openFeed(WidgetTester tester) async {
  await tester.pumpWidget(const StudentApp());
  await login(tester);
  await tab(tester, 'Social');
}

Future<void> createPost(WidgetTester tester, String caption) async {
  await tap(tester, find.byTooltip('Create Post'));
  await tester.enterText(field('post-caption'), caption);
  await tester.enterText(
    field('post-image'),
    'https://picsum.photos/id/20/600/400',
  );
  await tap(tester, field('submit-post'));
}

void main() {
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
    DemoAuth.logout();
  });

  testWidgets('Feed shows samples and validates, cancels and creates posts', (
    tester,
  ) async {
    await openFeed(tester);
    expect(find.text('JohnDoe'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('JaneSmith'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('JaneSmith'), findsOneWidget);
    await tap(tester, find.byTooltip('Create Post'));
    await tap(tester, field('submit-post'));
    expect(
      find.text('Complete both fields before submitting!'),
      findsOneWidget,
    );
    await tester.enterText(
      field('post-caption'),
      '  My first Flutter social media post!  ',
    );
    for (final url in [
      'not a URL',
      'ftp://example.com/photo.jpg',
      'https://',
      'http:///image.jpg',
      '[photo](https://example.com/image.jpg)',
    ]) {
      await tester.enterText(field('post-image'), url);
      await tap(tester, field('submit-post'));
      expect(
        find.text('Enter a valid HTTP or HTTPS image URL.'),
        findsOneWidget,
      );
      expect(find.byType(CreatePostSheet), findsOneWidget);
    }
    await tester.enterText(
      field('post-image'),
      ' https://picsum.photos/id/20/600/400 ',
    );
    await tap(tester, field('submit-post'));
    final post = card('My first Flutter social media post!');
    expect(post, findsOneWidget);
    expect(within(post, find.text('admin')), findsOneWidget);
    expect(
      tester.widgetList<PostCard>(find.byType(PostCard)).first.post.caption,
      'My first Flutter social media post!',
    );
    await tap(tester, find.byTooltip('Create Post'));
    await tester.enterText(field('post-caption'), 'Discard me');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard me'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Likes, comments and drafts survive insertion, scrolling and tabs',
    (tester) async {
      await openFeed(tester);
      final original = card(firstCaption);
      await tap(tester, within(original, find.text('Like')));
      expect(within(original, find.text('Liked')), findsOneWidget);
      await tap(tester, within(original, find.text('Liked')));
      expect(within(original, find.text('Like')), findsOneWidget);
      await tap(tester, within(original, find.text('Like')));
      await tester.enterText(within(original, find.byType(TextField)), '   ');
      await tap(tester, within(original, find.byTooltip('Send comment')));
      expect(within(original, find.text('0 Comments')), findsOneWidget);
      await tester.enterText(
        within(original, find.byType(TextField)),
        '  Great work!  ',
      );
      await tap(tester, within(original, find.byTooltip('Send comment')));
      expect(within(original, find.text('Great work!')), findsOneWidget);
      expect(within(original, find.text('1 Comments')), findsOneWidget);
      expect(
        tester
            .widget<TextField>(within(original, find.byType(TextField)))
            .controller!
            .text,
        isEmpty,
      );
      await tester.enterText(
        within(original, find.byType(TextField)),
        'Unsent draft',
      );
      // Make enough cards to evict the original from the visible list/cache.
      for (var i = 0; i < 4; i++) {
        await createPost(tester, 'New post $i');
      }
      final feed = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text(firstCaption),
        250,
        scrollable: feed,
      );
      expect(within(card(firstCaption), find.text('Liked')), findsOneWidget);
      expect(
        within(card(firstCaption), find.text('Great work!')),
        findsOneWidget,
      );
      await tab(tester, 'Dashboard');
      await tab(tester, 'Social');
      await tester.ensureVisible(
        within(card(firstCaption), find.byType(TextField)),
      );
      await tester.pumpAndSettle();
      expect(
        within(card(firstCaption), find.text('1 Comments')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(
              within(card(firstCaption), find.byType(TextField)),
            )
            .controller!
            .text,
        'Unsent draft',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Logout clears session and back route; registered posts use new username',
    (tester) async {
      await openFeed(tester);
      await createPost(tester, 'Admin only post');
      await tab(tester, 'Dashboard');
      await logout(tester);
      expect(DemoAuth.currentUsername, isNull);
      expect(find.byType(MainScreen), findsNothing);
      final context = tester.element(field('login'));
      expect(Navigator.of(context).canPop(), isFalse);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MainScreen), findsNothing);
      expect(field('login'), findsOneWidget);
      await register(tester, '  student557989  ', 'secret123');
      await login(tester, username: 'student557989', password: 'secret123');
      expect(DemoAuth.currentUsername, 'student557989');
      expect(find.text('Welcome, student557989!'), findsOneWidget);
      await tab(tester, 'Social');
      expect(find.text('Admin only post'), findsNothing);
      await createPost(tester, 'My registered account post');
      expect(
        within(card('My registered account post'), find.text('student557989')),
        findsOneWidget,
      );
      // A full fresh application session clears all feed interaction state.
      await tester.pumpWidget(const SizedBox.shrink());
      DemoAuth.registeredUsername = null;
      DemoAuth.registeredPassword = null;
      DemoAuth.logout();
      await tester.pumpWidget(const StudentApp());
      await login(tester);
      await tab(tester, 'Social');
      expect(find.text('My registered account post'), findsNothing);
      expect(find.text('JohnDoe'), findsOneWidget);
    },
  );

  testWidgets(
    'Network failures render an image placeholder without breaking interaction',
    (tester) async {
      // Widget tests block real HTTP requests, exercising the errorBuilder.
      await openFeed(tester);
      expect(find.text('Image unavailable'), findsWidgets);
      await tap(tester, within(card(firstCaption), find.text('Like')));
      expect(within(card(firstCaption), find.text('Liked')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Small screen and keyboard keep create form and comments accessible',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await openFeed(tester);
      await createPost(tester, 'Small screen post');
      final post = card('Small screen post');
      await tester.ensureVisible(within(post, find.byType(TextField)));
      await tester.pumpAndSettle();
      await tester.enterText(
        within(post, find.byType(TextField)),
        'Accessible comment',
      );
      await tap(tester, within(post, find.byTooltip('Send comment')));
      expect(within(post, find.text('Accessible comment')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
