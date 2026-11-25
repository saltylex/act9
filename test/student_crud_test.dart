import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasignasigna_navigation_app/student_crud_page.dart';

Finder field(String key) => find.byKey(ValueKey(key));

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Validation rejects empty, whitespace and overlong input; create trims values',
    (tester) async {
      final db = FakeFirebaseFirestore();
      final students = db
          .collection('users')
          .doc('test-user')
          .collection('students');
      await tester.pumpWidget(
        MaterialApp(home: StudentCrudPage(collection: students)),
      );
      await tester.pumpAndSettle();
      expect(find.text('No student records yet.'), findsOneWidget);
      await tap(tester, field('save-student'));
      expect(find.text('This field is required.'), findsNWidgets(2));
      await tester.enterText(field('student-name'), '   ');
      await tester.enterText(field('student-course'), '   ');
      await tap(tester, field('save-student'));
      expect((await students.get()).docs, isEmpty);
      await tester.enterText(field('student-name'), 'A' * 81);
      await tester.enterText(field('student-course'), 'BSIT');
      await tap(tester, field('save-student'));
      expect(find.text('Use no more than 80 characters.'), findsOneWidget);
      expect((await students.get()).docs, isEmpty);
      await tester.enterText(field('student-name'), '  Alex Santos  ');
      await tester.enterText(field('student-course'), '  BSIT  ');
      await tap(tester, field('save-student'));
      expect((await students.get()).docs.single.data(), {
        'name': 'Alex Santos',
        'course': 'BSIT',
      });
      expect(find.text('Alex Santos'), findsOneWidget);
      expect(find.text('Student added successfully.'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('student-name')).controller!.text,
        isEmpty,
      );
    },
  );

  testWidgets(
    'Edit targets the document ID, updates without duplication, and cancels edits',
    (tester) async {
      final db = FakeFirebaseFirestore();
      final students = db
          .collection('users')
          .doc('test-user')
          .collection('students');
      await students.doc('alex').set({'name': 'Alex Santos', 'course': 'BSIT'});
      await tester.pumpWidget(
        MaterialApp(home: StudentCrudPage(collection: students)),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byTooltip('Edit'));
      expect(
        tester.widget<TextFormField>(field('student-name')).controller!.text,
        'Alex Santos',
      );
      expect(
        tester.widget<TextFormField>(field('student-course')).controller!.text,
        'BSIT',
      );
      await tester.enterText(field('student-course'), 'BSCS');
      await tap(tester, field('save-student'));
      final records = (await students.get()).docs;
      expect(records.length, 1);
      expect(records.single.id, 'alex');
      expect(records.single.data()['course'], 'BSCS');
      await tap(tester, find.byTooltip('Edit'));
      await tester.enterText(field('student-name'), 'Unsaved change');
      await tap(tester, find.text('Cancel Edit'));
      expect(find.text('Edit Student'), findsNothing);
      expect(
        tester.widget<TextFormField>(field('student-name')).controller!.text,
        isEmpty,
      );
      expect((await students.doc('alex').get()).data()!['name'], 'Alex Santos');
    },
  );

  testWidgets(
    'Delete cancellation retains the record; confirmation deletes and clears its edit form',
    (tester) async {
      final db = FakeFirebaseFirestore();
      final students = db
          .collection('users')
          .doc('test-user')
          .collection('students');
      await students.doc('jamie').set({'name': 'Jamie Cruz', 'course': 'BSCS'});
      await tester.pumpWidget(
        MaterialApp(home: StudentCrudPage(collection: students)),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byTooltip('Delete'));
      expect(find.text('Delete Jamie Cruz?'), findsOneWidget);
      await tap(tester, find.text('Cancel'));
      expect((await students.doc('jamie').get()).exists, isTrue);
      await tap(tester, find.byTooltip('Edit'));
      await tap(tester, find.byTooltip('Delete'));
      await tap(tester, find.widgetWithText(TextButton, 'Delete'));
      expect((await students.doc('jamie').get()).exists, isFalse);
      expect(find.text('Edit Student'), findsNothing);
      expect(find.text('No student records yet.'), findsOneWidget);
      expect(find.text('Student deleted successfully.'), findsOneWidget);
    },
  );

  testWidgets(
    'Snapshot changes appear live and records load when the page reopens',
    (tester) async {
      final db = FakeFirebaseFirestore();
      final students = db
          .collection('users')
          .doc('test-user')
          .collection('students');
      await tester.pumpWidget(
        MaterialApp(home: StudentCrudPage(collection: students)),
      );
      await tester.pumpAndSettle();
      await students.doc('morgan').set({
        'name': 'Morgan Reyes',
        'course': 'BSIS',
      });
      await tester.pumpAndSettle();
      expect(find.text('Morgan Reyes'), findsOneWidget);
      await students.doc('morgan').update({'course': 'BSIT'});
      await tester.pumpAndSettle();
      expect(find.text('BSIT'), findsOneWidget);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpWidget(
        MaterialApp(home: StudentCrudPage(collection: students)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Morgan Reyes'), findsOneWidget);
      expect(find.text('BSIT'), findsOneWidget);
    },
  );
}
