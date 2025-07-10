=================================================================================
If your Flutter build fails with an error requesting Android NDK version 27.0.12077973:

ACTION REQUIRED: Install Android NDK 27.0.12077973

To resolve the build error do one of the following:
---------------------------------------------------------------------------------
Method 1: Using Android Studio (Recommended)
--------------------------------------------
1. Open Android Studio.
2. Go to Tools > SDK Manager > "SDK Tools" tab.
3. Check "Show Package Details" (bottom right).
4. Under "NDK (Side by side)", locate and tick version 27.0.12077973.
   (If not present, update your Android Studio and reload this list.)
5. Click OK/Apply and let the NDK install. Wait until complete.
6. After install, verify with:
   $ ls $ANDROID_SDK_ROOT/ndk/

Method 2: Via Command Line (sdkmanager)
---------------------------------------
1. Run:
   $ yes | ${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}/cmdline-tools/latest/bin/sdkmanager --install "ndk;27.0.12077973"
2. Wait for installation to finish. Check with:
   $ ls ${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}/ndk/

Method 3: Download Directly from Google (Advanced)
---------------------------------------------------
- Visit https://developer.android.com/ndk/downloads/older_releases and search for NDK 27.0.12077973.
- Download appropriate package and extract to your Android SDK's ndk directory.

---------------------------------------------------------------------------------
Once NDK is installed, re-run the build in your project directory:

$ cd personal-finance-tracker-33924/finance_frontend
$ flutter clean
$ flutter pub get
$ flutter build apk           (for Android release)
$ flutter run                 (to launch on attached emulator or device)

If you still encounter errors, update your SDK tools or reach out with the error details.
=================================================================================

SUMMARY: This manual step is necessary and not a codebase issue—install the specific NDK, then rebuild and run your Flutter app.
