import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasignasigna_navigation_app/demo_auth.dart';
import 'package:pasignasigna_navigation_app/main.dart';
import 'package:pasignasigna_navigation_app/login_screen.dart';
import 'package:pasignasigna_navigation_app/main_screen.dart';

Finder field(String key) => find.byKey(ValueKey(key));

Future<void> tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      80,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> login(
  WidgetTester tester, {
  String username = 'admin',
  String password = 'admin123',
}) async {
  await tester.enterText(field('username'), username);
  await tester.enterText(field('password'), password);
  await tap(tester, field('login'));
}

Future<void> register(
  WidgetTester tester,
  String username,
  String password,
) async {
  await tap(tester, field('open-register'));
  await tester.enterText(field('username'), username);
  await tester.enterText(field('password'), password);
  await tester.enterText(field('confirmation'), password);
  await tap(tester, field('register'));
}

Future<void> tab(WidgetTester tester, String label) =>
    tap(tester, find.widgetWithText(NavigationDestination, label));

Future<void> logout(WidgetTester tester) async {
  await tab(tester, 'Profile');
  await tap(tester, field('logout'));
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
    DemoAuth.logout();
  });

  test(
    'Demo accounts replace previous registration and preserve exact passwords',
    () {
      expect(DemoAuth.login('admin', 'admin123'), isTrue);
      expect(DemoAuth.currentUsername, 'admin');
      expect(DemoAuth.login('ADMIN', 'admin123'), isFalse);
      DemoAuth.register('jolex', ' pass123 ');
      expect(DemoAuth.login('jolex', 'pass123'), isFalse);
      expect(DemoAuth.login('jolex', ' pass123 '), isTrue);
      DemoAuth.register('newuser', 'secret');
      expect(DemoAuth.login('jolex', ' pass123 '), isFalse);
      expect(DemoAuth.login('newuser', 'secret'), isTrue);
      expect(DemoAuth.currentUsername, 'newuser');
      expect(DemoAuth.login('admin', 'admin123'), isTrue);
      DemoAuth.logout();
      expect(DemoAuth.currentUsername, isNull);
      expect(DemoAuth.registeredUsername, 'newuser');
    },
  );

  testWidgets(
    'Login validates, toggles password, rejects invalid credentials and opens Dashboard',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      expect(find.byType(LoginScreen), findsOneWidget);
      await tap(tester, field('login'));
      expect(find.text('Enter your username.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
      await tap(tester, find.byTooltip('Show password'));
      final passwordField = find.descendant(
        of: field('password'),
        matching: find.byType(TextField),
      );
      expect(tester.widget<TextField>(passwordField).obscureText, isFalse);
      await login(tester, password: 'wrong');
      expect(find.text('Invalid username or password.'), findsOneWidget);
      await login(tester, username: ' admin ');
      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.text('Welcome, admin!'), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(
        tester
            .widgetList<NavigationDestination>(
              find.byType(NavigationDestination),
            )
            .map((destination) => destination.label),
        ['Dashboard', 'Calculator', 'Social', 'Profile'],
      );
      expect(find.byType(LoginScreen), findsNothing);
    },
  );

  testWidgets(
    'Registration validates reserved names, length and confirmation',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      await tap(tester, field('open-register'));
      await tap(tester, field('register'));
      expect(find.text('Use at least 3 characters.'), findsOneWidget);
      expect(find.text('Enter a password.'), findsOneWidget);
      expect(find.text('Confirm your password.'), findsOneWidget);
      await tester.enterText(field('username'), ' AdMiN ');
      await tester.enterText(field('password'), '12345');
      await tester.enterText(field('confirmation'), 'other');
      await tap(tester, field('register'));
      expect(find.text('This username is reserved.'), findsOneWidget);
      expect(find.text('Use at least 6 characters.'), findsOneWidget);
      expect(find.text('Passwords do not match.'), findsOneWidget);
      await tester.enterText(field('password'), '      ');
      await tap(tester, field('register'));
      expect(find.text('Enter a password.'), findsOneWidget);
      await tester.enterText(field('username'), ' jolex ');
      await tester.enterText(field('password'), ' secret ');
      await tester.enterText(field('confirmation'), ' secret ');
      await tap(tester, find.byTooltip('Show password'));
      await tap(tester, find.byTooltip('Show confirmation password'));
      await tap(tester, field('register'));
      expect(
        find.text('Registration successful! You can now log in.'),
        findsOneWidget,
      );
      await login(tester, username: 'jolex', password: ' secret ');
      expect(find.text('Welcome, jolex!'), findsOneWidget);
      await tab(tester, 'Profile');
      expect(find.text('Logged in as: jolex'), findsOneWidget);
      await logout(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      await register(tester, 'replacement', 'secret2');
      await login(tester, username: 'jolex', password: ' secret ');
      expect(find.text('Invalid username or password.'), findsOneWidget);
      await login(tester, username: 'replacement', password: 'secret2');
      expect(find.byType(MainScreen), findsOneWidget);
      await logout(tester);
      await login(tester);
      expect(find.byType(MainScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Calculator performs all operations and preserves state through every tab',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      await login(tester);
      await tab(tester, 'Calculator');
      await tester.enterText(field('first-number'), ' -7.5 ');
      await tester.enterText(field('second-number'), '2.5');
      for (final operation in [
        ('Add', '-7.5 + 2.5 = -5.0'),
        ('Subtract', '-7.5 − 2.5 = -10.0'),
        ('Multiply', '-7.5 × 2.5 = -18.75'),
        ('Divide', '-7.5 ÷ 2.5 = -3.0'),
      ]) {
        await tap(tester, field(operation.$1));
        expect(find.text(operation.$2), findsOneWidget);
      }
      await tab(tester, 'Profile');
      expect(find.text('Logged in as: admin'), findsOneWidget);
      expect(find.text('557989'), findsOneWidget);
      expect(find.text('Jolex129@gmail.com'), findsOneWidget);
      expect(find.text('BSIT — 3rd Year'), findsOneWidget);
      await tab(tester, 'Social');
      await tap(tester, find.byTooltip('My social links'));
      for (final account in [
        ('Facebook', 'Facebook: jolex.pasignasigna'),
        ('Instagram', 'Instagram: @_p.jlx'),
        ('TikTok', 'TikTok: @xophiasbrother'),
      ]) {
        await tap(tester, find.text(account.$1));
        expect(find.text('Selected account: ${account.$2}'), findsOneWidget);
      }
      expect(find.text('YouTube'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tab(tester, 'Dashboard');
      await tab(tester, 'Calculator');
      expect(find.text('-7.5 ÷ 2.5 = -3.0'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('first-number')).controller!.text,
        ' -7.5 ',
      );
      await tap(tester, find.text('Clear'));
      expect(
        tester.widget<TextFormField>(field('first-number')).controller!.text,
        isEmpty,
      );
      expect(
        tester.widget<TextFormField>(field('second-number')).controller!.text,
        isEmpty,
      );
      expect(
        find.text('Enter two numbers and choose an operation.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Calculator rejects empty, invalid, nonfinite, zero division and overflow',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      await login(tester);
      await tab(tester, 'Calculator');
      await tap(tester, field('Add'));
      expect(find.text('Enter a number.'), findsNWidgets(2));
      for (final value in ['abc', 'NaN', 'Infinity', '1e999']) {
        await tester.enterText(field('first-number'), value);
        await tester.enterText(field('second-number'), '2');
        await tap(tester, field('Add'));
        expect(find.text('Enter a valid finite number.'), findsOneWidget);
      }
      await tester.enterText(field('first-number'), '10');
      await tester.enterText(field('second-number'), '0');
      await tap(tester, field('Divide'));
      expect(find.text('Cannot divide by zero.'), findsNWidgets(2));
      await tester.enterText(field('second-number'), '2');
      await tap(tester, field('Divide'));
      expect(find.text('10.0 ÷ 2.0 = 5.0'), findsOneWidget);
      await tester.enterText(field('first-number'), '1e308');
      await tester.enterText(field('second-number'), '1e308');
      await tap(tester, field('Multiply'));
      expect(
        find.text('Result is too large. Try smaller numbers.'),
        findsOneWidget,
      );
      await tap(tester, find.text('Clear'));
      expect(find.text('Enter a valid finite number.'), findsNothing);
    },
  );

  testWidgets('Personal profile links copy the exact supplied URLs', (
    tester,
  ) async {
    String? copiedLink;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedLink = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(const StudentApp());
    await login(tester);
    await tab(tester, 'Social');
    await tap(tester, find.byTooltip('My social links'));
    for (final profile in [
      ('Facebook', 'https://www.facebook.com/jolex.pasignasigna'),
      ('Instagram', 'https://www.instagram.com/_p.jlx/'),
      ('TikTok', 'https://www.tiktok.com/@xophiasbrother'),
    ]) {
      await tap(tester, find.text(profile.$1));
      await tap(tester, find.text('Copy link'));
      expect(copiedLink, profile.$2);
      expect(find.text('Profile link copied.'), findsOneWidget);
    }
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tab(tester, 'Profile');
    expect(find.text('JP'), findsOneWidget);
    expect(find.text('j.pasignasigna.557989@umindanao.edu.ph'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Gaming'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('About Me'), findsOneWidget);
    expect(find.text('Gaming'), findsOneWidget);
    expect(find.text('Riding'), findsOneWidget);
    expect(find.text('Listening to music'), findsOneWidget);
    await tap(tester, find.text('Student Profile Repository'));
    await tap(tester, find.text('Copy link'));
    expect(copiedLink, 'https://github.com/saltylex/student_profile_app');
  });

  testWidgets(
    'Lab 7 calculator checkpoints use decimal results and retain state',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      await login(tester);
      await tab(tester, 'Calculator');
      await tester.enterText(field('first-number'), '20');
      await tester.enterText(field('second-number'), '5');
      for (final operation in [
        ('Add', '20.0 + 5.0 = 25.0'),
        ('Subtract', '20.0 − 5.0 = 15.0'),
        ('Multiply', '20.0 × 5.0 = 100.0'),
        ('Divide', '20.0 ÷ 5.0 = 4.0'),
      ]) {
        await tap(tester, field(operation.$1));
        expect(find.text(operation.$2), findsOneWidget);
      }
      await tester.enterText(field('first-number'), '10');
      await tap(tester, field('Add'));
      expect(find.text('10.0 + 5.0 = 15.0'), findsOneWidget);
      await tab(tester, 'Dashboard');
      await tab(tester, 'Social');
      await tab(tester, 'Profile');
      await tab(tester, 'Calculator');
      expect(find.text('10.0 + 5.0 = 15.0'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('first-number')).controller!.text,
        '10',
      );
      expect(
        tester.widget<TextFormField>(field('second-number')).controller!.text,
        '5',
      );
    },
  );

  testWidgets(
    'Small screen and keyboard allow registration, navigation and calculator',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(const StudentApp());
      await register(tester, 'jolex', 'secret');
      await login(tester, username: 'jolex', password: 'secret');
      await tab(tester, 'Calculator');
      await tester.enterText(field('first-number'), '5');
      await tester.enterText(field('second-number'), '2');
      await tap(tester, field('Add'));
      await tab(tester, 'Profile');
      await tab(tester, 'Social');
      await tab(tester, 'Calculator');
      expect(find.text('5.0 + 2.0 = 7.0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
