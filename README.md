# Laboratory Activity 9: Cloud Firestore CRUD

Jolex Pasignasigna | Student ID 557989 | BS Information Technology, 3rd Year | CCE106L (3450)

Academic Period: 2026–2027, First Semester, Second Term.

Continues the Firebase-enabled Activity 8 application in a separate Lab-09 folder. Dashboard ? **Manage Student Records** opens the student module. The existing Login, Register, Calculator, Social, and Profile pages remain available.

## Run in Chrome

```powershell
git clone https://github.com/saltylex/act9.git
cd act9
flutter pub get
flutter run -d chrome --web-port 7359
```

In the combined lab workspace, use `Lab-Activities/Lab-09` as the project root instead.

On this Windows computer, set the Chrome path if Flutter cannot find it:

```powershell
$env:CHROME_EXECUTABLE = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
flutter run -d chrome --web-port 7359
```

Login: **admin / admin123**. Open Dashboard ? Manage Student Records. The AppBar Back button returns to Dashboard.

## Firebase setup

- Firebase project: `pasignasigna-student-557989`, the same project as Activity 8.
- Database: `(default)`, Firestore Standard, `asia-southeast1` (Singapore).
- Firebase Anonymous Authentication is enabled.
- `main.dart` initializes Firebase, signs in anonymously when no Firebase user exists, then opens the existing DemoAuth interface.
- `lib/firebase_options.dart` was generated with FlutterFire for Web.
- `firestore.rules` contains the instructor's owner-only path and two-field validation rules; these rules have been published.
- `firebase.json` includes anonymous provider configuration and the Firestore rules file.

To reconfigure and redeploy from the project root:

```powershell
firebase login
flutterfire configure --project=pasignasigna-student-557989 --platforms=web
firebase deploy --only auth,firestore:rules --project pasignasigna-student-557989
```

DemoAuth is a classroom login interface, separate from Firebase Authentication. Different DemoAuth usernames in the same anonymous Firebase session share records. Keep the same browser profile and session during demonstrations; a new anonymous identity accesses a different collection. Flutter may open a fresh browser profile on a later `flutter run -d chrome`, so keep the current preview window for the captured demonstration records.

## Data and operations

Path: `users/{Firebase UID}/students/{generated document ID}`.

Each document contains exactly two strings: `name` and `course`. The form trims both values, rejects empty or whitespace-only inputs, and limits each to 80 characters. Firestore rules independently validate ownership, field names, types, and lengths.

| Operation | Implementation |
| --- | --- |
| Create | `students.add(data)` |
| Read | `students.snapshots()` rendered by StreamBuilder |
| Update | `students.doc(id).update(data)` |
| Delete | `students.doc(id).delete()` after confirmation |

Save and Delete disable competing form actions. Saving errors and deletion errors show Firebase error codes; stream errors show a connection/rules message.

## Actual verification

Verified November 25, 2026:

- Static analysis: no issues found.
- Automated tests: all **17 passed**, including four new CRUD tests and 13 existing application tests.
- Chrome: Firebase initialized, anonymous sign-in completed, demo login opened Dashboard, and the Dashboard button opened Student Records.
- Empty and whitespace-only fields were rejected in Chrome.
- Alex Santos / BSIT, Jamie Cruz / BSCS, and Morgan Reyes / BSIS were added in the app and confirmed in Firestore.
- Alex's course changed to BSCS in the same document; the collection count stayed at three.
- Cancel Edit returned to Add Student without changing the stored record.
- Cancel deletion kept Jamie; confirming deletion removed Jamie from both the UI and Firestore.
- Leaving and reopening Student Records reloaded Alex / BSCS and Morgan / BSIS.
- Live security checks: owner read allowed; unauthenticated and other-user reads denied; missing, extra, and overlong fields denied.

Run the automated checks with `flutter analyze` and `flutter test`. Test doubles verify widget behavior; the separate browser checks used the actual Firebase project and database.

## Submission artifacts

- [Google Docs report](https://docs.google.com/document/d/1ghIeIlFNhws5lQ9s90bJpSEnB4WYRzHwVv_b4ZB6Gt8/edit)
- [PDF documentation](submission/Pasignasigna_Activity_9.pdf): exported from Google Docs, including the completed testing table, guide answers, and seven required screenshots.
- [Screenshots ZIP](submission/Activity-9-Screenshots.zip)
- `submission/screenshots/`: form, three records, update before/after, delete confirmation/result, Firestore Console, validation, and reopening.
- `submission/verification-results.json`: actual document IDs and values before/after the verified operations, plus security check results. No authentication tokens are included.

## References

- [Firebase anonymous authentication](https://firebase.google.com/docs/auth/web/anonymous-auth)
- [Firestore data model](https://firebase.google.com/docs/firestore/data-model)
- [Realtime listeners](https://firebase.google.com/docs/firestore/query-data/listen)
- [Security rule conditions](https://firebase.google.com/docs/firestore/security/rules-conditions)
