# MediReminder

MediReminder is a student-friendly Flutter prototype for organizing medicine and vitamin schedules. It uses a premium dark violet interface inspired by the supplied UI collage.

## Features
- Local prototype sign-up, login, logout, and password reset
- Add, view, edit, activate/deactivate, and delete medicine records
- Daily schedule and reminder-time display
- Local notification scheduling (device permission and platform setup required)
- Taken/missed history entries and basic adherence insights
- Profile information and app preferences
- Dark violet theme and responsive scrolling layouts

## Run in VS Code
1. Extract the ZIP.
2. Open the `medi_reminder` folder in VS Code.
3. Open Terminal in the project folder.
4. Run `flutter pub get`.
5. Run `flutter run`.

This archive contains the complete Dart application source. Flutter and Dart SDKs are not installed in the file-generation environment, so it has not been compiled here. The `android/` and `ios/` folders contain setup notes rather than generated native runner projects. To generate native platform scaffolding, run:

```bash
flutter create --platforms=android,ios .
flutter pub get
flutter run
```

If you only target Android, use `flutter create --platforms=android .`.

## Where to edit things
- Colors: `lib/core/theme/app_colors.dart`
- Theme and typography: `lib/core/theme/app_theme.dart`, `app_text_styles.dart`
- Navigation: `lib/core/routes/app_routes.dart`
- Authentication: `lib/services/auth_service.dart`
- Medicine records: `lib/services/medicine_service.dart`
- Notifications: `lib/services/notification_service.dart`
- Screens: `lib/features/`
- Reusable UI: `lib/widgets/`
- Images: `assets/images/` (the UI works without custom images)

## Local prototype authentication
Accounts are stored on the device using SharedPreferences. This is suitable only for a classroom prototype. Passwords are stored locally and are **not securely hashed or protected**. Do not use real passwords or treat this as production authentication. A production app should use a secure backend and a proper authentication provider.

## Reminder notes
The app requests notification permission and schedules local notifications on supported devices. Android exact-alarm behavior and iOS permissions depend on the OS version and device settings. A denied permission may prevent alerts. A reminder is an organizational aid only; follow the instructions given by a qualified healthcare professional and the medicine label. MediReminder does not recommend medicines or determine doses.

## Assets
Place optional images in `assets/images/` and icons in `assets/icons/`. Avoid referencing an asset in Dart until it exists in the folder and is declared in `pubspec.yaml`.

## App name
The Flutter package name is `medi_reminder`. The visible app title is configured in `lib/main.dart`. Native launcher names/icons can be changed in the generated Android/iOS runner projects.


## Android notification permission
After generating the Android runner, open `android/app/src/main/AndroidManifest.xml` and add this permission directly inside the root `<manifest>` element (before `<application>`):

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

The app requests notification permission at runtime from Settings. On some Android versions, scheduled alarms may be delayed by battery optimization. This prototype schedules the next reminder occurrence; it does not yet implement a full recurring multi-dose scheduler.

## Prototype scope notes
- The Snooze action schedules a one-time alert 15 minutes later.
- Backup/restore, gallery profile-photo selection, and external support messaging are presented as unavailable prototype actions rather than pretending to complete them.
- History records actions the user marks as Taken. Missed doses are not inferred automatically.
