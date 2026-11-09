# MediReminder – Medicine and Vitamins Reminder App

MediReminder is a mobile application developed using Flutter and Dart. Its main purpose is to help users organize their medicine and vitamin schedules and remember when to take them through scheduled notifications.

The application provides a simple and user-friendly way to manage medicine records, set reminder schedules, and monitor medicine activities.

## Features

- User registration and login using Firebase Authentication
- Add, view, edit, activate, and deactivate medicine records
- Delete medicine records
- Add medicines and vitamins
- Set medicine dosage and frequency
- Set specific reminder times
- Set medicine start and end dates
- Schedule daily medicine and vitamin reminders
- Snooze reminders for 15 minutes
- Mark medicine activities as Taken or Missed
- View medicine activity History
- Automatic missed-dose recording when the app reconciles schedules
- Profile information and application settings
- Simple and user-friendly interface

## Technologies Used

- **Flutter** – Mobile application framework
- **Dart** – Programming language
- **Firebase Authentication** – User registration and login
- **SharedPreferences** – Local storage for medicine records and History
- **Flutter Local Notifications** – Scheduled medicine reminders
- **Android Studio** – Android development environment
- **Visual Studio Code** – Code editor

## How to Run the Project

### Requirements

Before running the application, make sure you have installed:

- Flutter SDK
- Dart SDK
- Android Studio
- Visual Studio Code
- Git

### Installation Steps

1. Clone or download this repository from GitHub.
2. Open the project folder named `medi_reminder` in Visual Studio Code.
3. Open the terminal in the project folder.
4. Install the required dependencies:

```bash
flutter pub get
```

5. Check your Flutter environment:

```bash
flutter doctor
```

6. Connect an Android device or start an Android emulator.
7. Run the application:

```bash
flutter run
```

## Project Structure

The project is organized into different folders to make the application easier to manage and maintain.

```text
medi_reminder/
│
├── android/
│   └── Android application configuration
│
├── assets/
│   ├── images/
│   └── icons/
│
├── lib/
│   │
│   ├── core/
│   │   ├── constants/
│   │   ├── routes/
│   │   ├── theme/
│   │   └── utils/
│   │
│   ├── features/
│   │   ├── about/
│   │   ├── auth/
│   │   ├── help/
│   │   ├── history/
│   │   ├── home/
│   │   ├── insights/
│   │   ├── medicine/
│   │   ├── notifications/
│   │   ├── onboarding/
│   │   ├── profile/
│   │   ├── schedule/
│   │   └── splash/
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── medicine_service.dart
│   │   ├── notification_service.dart
│   │   └── storage_service.dart
│   │
│   ├── widgets/
│   │
│   ├── firebase_options.dart
│   └── main.dart
│
├── test/
│
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── README.md
└── .gitignore
```

## Authentication System

MediReminder uses Firebase Authentication for user registration and login.

Users can create an account and log in to access the application's features.

## Data Storage

The application uses SharedPreferences to store medicine records and History entries locally on the device.

**Important:** Medicine records and History are stored locally. They are not automatically synchronized between different devices. Firebase is currently used for authentication.

## Notification System

MediReminder uses Flutter Local Notifications to remind users about their medicine and vitamin schedules.

Users can:

- Set specific reminder times.
- Receive scheduled daily reminders on supported Android devices.
- Snooze reminders for 15 minutes.
- Manage their medicine reminder schedules.

Notification delivery depends on device permissions, Android settings, and battery optimization. Some notifications may be delayed or unavailable if permissions are disabled.

## History and Medicine Tracking

The History feature allows users to view their recorded medicine activities.

Users can mark medicine activities as Taken or Missed. The application also has missed-dose reconciliation when schedules are checked, subject to its configured grace period.

The History feature helps users review their recorded medicine activities.

## Project Purpose

The main purpose of MediReminder is to help users organize their medicine and vitamin schedules in one application.

It aims to make medicine schedule management easier and more convenient by providing scheduled reminders and a History feature.

MediReminder is an organizational tool only. It does not recommend medicines, prescribe treatments, or determine dosages. Users should follow the instructions provided by qualified healthcare professionals and medicine labels.

## Future Improvements

Possible improvements for future versions include:

- Cloud backup and synchronization of medicine records
- Improved medicine History and reports
- Additional notification customization
- More application personalization options

## Developer

**Project Name:** MediReminder – Medicine and Vitamins Reminder App

**Platform:** Android

**Framework:** Flutter

**Programming Language:** Dart

**Project Type:** Mobile Application Project
