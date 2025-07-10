=================================================================================
If your Flutter build fails with an error requesting Android NDK version 27.0.12077973:

ACTION REQUIRED: Install Android NDK 27.0.12077973

---------------------------------------------------------------------------------
Most developers should use **Android Studio's SDK Manager** to install NDK.
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
For Local Flutter App Development (Recommended)
---------------------------------------------------------------------------------
- All steps above install the required NDK version for local builds.
- Once installed, simply run:

  flutter run
  flutter build apk

- No Docker or container setup is needed unless you are maintaining CI infrastructure.

---------------------------------------------------------------------------------
[For Automation/CI/Docker Use Only] — Automating NDK installation and permissions
---------------------------------------------------------------------------------
_The following section is for CI/CD engineers or those scripting container builds only._

# Set this path according to your Docker/CI environment:
export ANDROID_SDK_ROOT=/opt/android-sdk-linux

# 1. Install the required NDK:
yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT --install "ndk;27.0.12077973"

# 2. Verify install (should list 27.0.12077973):
ls -l $ANDROID_SDK_ROOT/ndk/

# 3. (Important) Ensure SDK dir is readable (needed for CI/runner/docker):
chmod -R a+rX $ANDROID_SDK_ROOT
chown -R $(id -u):$(id -g) $ANDROID_SDK_ROOT

# 4. For Dockerfile — sample excerpt:
# ENV ANDROID_SDK_ROOT=/opt/android-sdk-linux
# RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install "ndk;27.0.12077973"
# RUN chmod -R a+rX ${ANDROID_SDK_ROOT} && chown -R root:root ${ANDROID_SDK_ROOT}

# 5. Then run your Gradle/Flutter build:
flutter build apk
flutter run

# If your app's android/app/build.gradle(.kts) file specifies an ndkVersion, you may remove/comment the ndkVersion assignment to allow the build to use any available installed NDK version.
# In your project, build.gradle.kts does NOT pin ndkVersion; no code change is needed.

NOTE: If you encounter a build error like "Could not find an option named 'no-sound-null-safety'", remove the "--no-sound-null-safety" flag from run scripts/commands, as it is deprecated in recent Flutter versions.

If you still encounter errors, update your SDK tools or contact project maintainers with the error details.
=================================================================================

SUMMARY: Install Android NDK 27.0.12077973 via Android Studio (preferred) or command line if you encounter a build error. Primary development and builds are **intended to use your local Flutter and Android toolchain**. Docker/CI setup is not needed for day-to-day development.
