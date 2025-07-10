# finance_frontend

A modern Flutter app for personal finance tracking.

---

## 🚀 Native Flutter Development & Android/iOS Build

This project is designed to be developed and built **locally** with your own Flutter installation. **Do NOT use Docker or containerized tools for main development.**

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **(version 3.22+ recommended)**
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- **Android Studio** (with Android SDK, NDK, tools <br>
  _OR_ <br>
  **Xcode** (for iOS, on macOS only)
- Device or emulator (Android/iOS) for testing

> **TIP:** The official [Flutter Install Guide](https://docs.flutter.dev/get-started/install) covers Windows, macOS, and Linux with common troubleshooting.

---

## 🛠️ Setup Instructions

1. **Install Flutter and Devices**
   - Ensure `flutter doctor` passes (fix all issues for your platform):
     ```
     flutter doctor
     ```

2. **Clone the repo**
   ```
   git clone <REPO_URL>
   cd finance_frontend
   ```

3. **Install Dart/Flutter Dependencies**
   ```
   flutter pub get
   ```

4. **Android NDK Requirement**

   If you see a build failure mentioning:
   ```
   NDK version 27.0.12077973 required
   ```
   _Follow instructions in_ `README_NDK_NOTE.txt` _in this directory._

---

## 💻 Running the App Locally

#### To launch on your device or emulator:

```
flutter run
```

#### To build a release APK (Android):

```
flutter build apk
```

#### To build for iOS (on Mac):

```
flutter build ios
```

---

## 🔎 Testing

Run widget/unit tests with:

```
flutter test
```

---

## 🌐 Useful Flutter References

- [Flutter Codelabs](https://docs.flutter.dev/get-started/codelab)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools/overview)

---

## 📝 Troubleshooting

- **NDK/SDK errors:** See [`README_NDK_NOTE.txt`](README_NDK_NOTE.txt) for NDK version fixes.
- **Permission Issues:** Make sure your user account owns the Flutter/SDK project directories.
- **No device detected?** Use `flutter devices`, run an emulator, or connect your phone with developer mode.

---

## ❌ Docker/Dev Container Use

This project is intended for **local development with your own installed Flutter tools**. _Dockerfiles and Devcontainer scripts are not maintained or recommended for end users or primary development._  
If you are maintaining CI/CD builds, see NDK install guidance in `README_NDK_NOTE.txt`.

---
