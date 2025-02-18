# Leanware Assessment

This is the repository for the **Leanware Assessment** project.

## Business Context

The **Leanware Technical Assessment – Flutter** project involves developing a cross-platform (Web, Android, iOS) video call application using Flutter. The application enhances the Agora Flutter SDK example with additional features, including:
- User registration
- Waiting room functionality
- Call timeout
- Optional blur effect
- Entry notifications

## Requirements

Before getting started, make sure you have the following installed on your local machine:

- [Flutter](https://flutter.dev/docs/get-started/install) (recommended version 3.27.4)
- [Dart](https://dart.dev/get-dart)
- [Xcode](https://developer.apple.com/xcode/) (macOS only)
- [Android Studio](https://developer.android.com/studio) or any other editor that supports Flutter.

## Cloning the Repository

First, clone this repository to your local machine:

```bash
git clone https://github.com/bedoyalejandra/leanware_assessment.git
cd leanware_assessment
```

## Installing Dependencies

After cloning the repository, navigate to the project folder and install the necessary dependencies:

```bash
flutter pub get
```

## Running the Application

To run the application, follow these steps:

1. **Connect a Device or Start an Emulator**
   Make sure you have an Android or iOS device connected, or start an emulator.

2. **Check Available Devices**
   Run the following command to check if a device or emulator is available:

   ```bash
   flutter devices
   ```

   If no devices are listed, start an emulator from Android Studio or connect a physical device.

3. **Run the App**
   Use the following command to launch the application:

   ```bash
   flutter run
   ```

## Additional Commands

- **Run on a Specific Device:** If multiple devices are available, you can specify one:

  ```bash
  flutter run -d <device_id>
  ```
  You can get the device ID from `flutter devices`.

- **Run with Hot Reload:** While the app is running, you can press `r` in the terminal to enable hot reload.
- **Run with Hot Restart:** Press `R` in the terminal to restart the app.

## Building the App

To generate a release build for Android:

```bash
flutter build apk
```

For iOS (macOS only):

```bash
flutter build ios
```

## Deploy Web App

To generate a release build for Web:

```bash
flutter build web
```

Deploy:

```bash
firebase deploy
```

## Troubleshooting

If you encounter issues, try the following:

- Run `flutter doctor` to check for missing dependencies.
- Ensure all required software is installed and up to date.
- Restart your IDE or terminal if needed.

For more details, refer to the [Flutter documentation](https://flutter.dev/docs).

