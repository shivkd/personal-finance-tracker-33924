=================================================================================
If your Flutter build fails with an error requesting Android NDK version 27.0.12077973 **or** you see:

    "Failed to install SDK components: ndk;27.0.12077973"
    "Failed to read or create install properties file"
    "NDK version 27.0.12077973 required" OR "NDK not installed: 27.0.12077973"
    or Flutter/Gradle build stalls on downloading NDK...

ACTION REQUIRED: Install Android NDK 27.0.12077973 *locally* using the RIGHT method for your system.

---------------------------------------------------------------------------------
**Native Desktop/Local Developers: Use THIS Guidance For Android NDK Fix**
---------------------------------------------------------------------------------

**Key things to know:**
- The build *will not* auto-install NDK 27 via the Flutter/Gradle scripts if your Android Studio or SDK Manager (CLI) are misconfigured or your file permissions/environment are wrong.
- Do *not* try to run container/Docker install commands on your local system.
- If you use Android Studio, prefer its graphical SDK Manager. If you use CLI, see below.
- If you have a custom Android SDK location, ensure your `local.properties` (`android/local.properties`) `sdk.dir` is correct and writable.

---------------------------------------------------------------------------------
Most developers should use **Android Studio's SDK Manager** to install NDK.
---------------------------------------------------------------------------------

Method 1: Using Android Studio (Recommended for Most)
-----------------------------------------------------
1. Open Android Studio.
2. Go to: **Tools > SDK Manager**.
3. Click on **"SDK Tools" tab**.
4. Check the box for **"Show Package Details"** (lower right corner).
5. Under **"NDK (Side by side)"**, find and tick version **27.0.12077973**.
   - If this version is not listed, fully update Android Studio, restart, and reload SDK Manager.
6. Click OK/Apply and **wait until the NDK finishes installing** (do not close Android Studio too soon).
7. Verify installation with:
   ```bash
   ls $ANDROID_SDK_ROOT/ndk/
   ```
   or, if not set, check the typical location:
   ```bash
   ls ~/Android/Sdk/ndk/
   ```
   ...should list a directory "27.0.12077973"

Method 2: Via Command Line (sdkmanager / Advanced)
--------------------------------------------------
1. Make sure your Android command line tools are installed and your SDK is up to date.
2. Run (Linux/Mac):
   ```bash
   export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
   yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --install "ndk;27.0.12077973"
   ```
   (You may need to run as your own user or use `sudo` to fix permissions.)

   For Windows (CMD/PowerShell):
   ```
   set ANDROID_SDK_ROOT=%UserProfile%\AppData\Local\Android\Sdk
   "%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat" --install "ndk;27.0.12077973"
   ```

3. After install completes, check with:
   ```bash
   ls $ANDROID_SDK_ROOT/ndk/
   ```
   (Should list "27.0.12077973")

Method 3: Download Directly from Google (Advanced)
---------------------------------------------------
- Visit https://developer.android.com/ndk/downloads/older_releases and search for NDK 27.0.12077973.
- Download appropriate package and extract to your Android SDK's ndk directory.

---------------------------------------------------------------------------------
**Important: Check your Android SDK Path!**
---------------------------------------------------------------------------------
- This project hardcodes the SDK path for Docker/CI as `/opt/android-sdk-linux`, but **your local setup is usually at `~/Android/Sdk`**.
- Check your `finance_frontend/android/local.properties` file. It should contain something like:
    ```
    sdk.dir=/home/<yourusername>/Android/Sdk
    ```
  - On Windows, it could be: `C:\\Users\\<yourusername>\\AppData\\Local\\Android\\Sdk`
  - If the path is wrong, update it! (Do NOT use `/opt/android-sdk-linux` unless your SDK is really there.)

---------------------------------------------------------------------------------
For Local Flutter App Development (Recommended)
---------------------------------------------------------------------------------
- Once steps above are complete, you should have:
    - NDK 27.0.12077973 in `$ANDROID_SDK_ROOT/ndk/`
    - Correct `sdk.dir` in `android/local.properties` pointing to your SDK.

- Now, run your builds:

  ```bash
  flutter run
  flutter build apk
  ```

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

Troubleshooting Matrix (Quick Reference)
---------------------------------------
| Error Message                                                           | Likely Cause / Solution                             |
|-------------------------------------------------------------------------|-----------------------------------------------------|
| "NDK version 27.0.12077973 required" or "NDK not installed"             | Install NDK 27 via Android Studio SDK Manager or CLI|
| "Failed to install SDK components: ndk;27.0.12077973"                   | Permissions OR wrong `sdk.dir` in local.properties  |
| "Failed to read or create install properties file"                      | Fix folder/file permissions; correct SDK path       |
| NDK version is not listed in Android Studio                             | Update Android Studio, then reload SDK Manager      |
| NDK installs but build still fails                                      | Restart Android Studio; double-check local.properties|
| File permission errors on Windows                                       | Run Studio/Terminal as Administrator; fix permissions|
| "Could not find option named 'no-sound-null-safety'"                    | Remove "--no-sound-null-safety" from build commands |

=================================================================================

SUMMARY: 
- Install Android NDK 27.0.12077973 using Android Studio (best) **or CLI** (if advanced).
- Make sure your local.properties points to your actual SDK.
- Ensure your SDK/NKD folders are fully **writable** by your user.
- For most build issues, it is a local SDK misconfiguration or missing permissions/file permissions.
- This project is designed for **native dev** (no Docker required).

If you get stuck:  
- Update all SDK tools.  
- Re-check your SDK directory and file permissions.  
- Remove any hardcoded `ndkVersion` from gradle if you've updated from other projects.  
- Contact project maintainers with all error logs.

=================================================================================
