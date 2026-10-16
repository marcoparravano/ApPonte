# ApPonte

ApPonte is a Flutter starter app for members of **Quartiere Ponte**. The project is structured for Android and iOS and includes a community splash screen, a section-based home page, a light/dark appearance setting, and an interactive score calculator.

## Run the app

From this directory, fetch the packages and launch the app on a connected Android device or emulator:

```sh
flutter pub get
flutter run
```

The Android and iOS platform folders are already included. Android builds need the Android SDK and device tools from Android Studio. iOS builds need macOS and Xcode; open `ios/Runner.xcworkspace` there to configure signing and device settings.

## Data

The app uses SQLite (`sqflite`) for community content on Android and iOS. The database is created at first launch and includes tables for announcements, events, and social posts. The theme choice is a small device preference stored with `shared_preferences`.

The initial content is sample data to make the interface useful immediately. Replace it with a remote community service when the app needs to share live content across members' devices; local SQLite alone is per-device storage.
