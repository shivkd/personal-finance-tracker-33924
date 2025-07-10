# ------------------------------------------------------------------------------
# Dockerfile for Flutter Mobile Development with Android SDK/NDK (VS Code Dev Containers compatible)
#
# This Dockerfile sets up a ready-to-develop environment for Flutter and Android,
# including Android SDK, cmdline-tools, and NDK 27.0.12077973 (required by Flutter builds).
# Developed for use with VS Code Dev Containers but works for general Docker builds.
#
# Major Steps:
#   1. Base OS, install required tools and OpenJDK 17
#   2. Install Flutter SDK
#   3. Install Android SDK, cmdline-tools, and Platform/NDK
#   4. Set environment variables for Android development
#   5. Final steps for permissions and VS Code compatibility
# ------------------------------------------------------------------------------

# 1. Base Image (Debian/Ubuntu LTS) & Core Dependencies
FROM ubuntu:22.04

# Prevent interactive prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for Flutter & Android SDK/NDK
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip git xz-utils zip \
    lcov \
    ca-certificates \
    build-essential \
    wget \
    libglu1-mesa \
    openjdk-17-jdk \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Install Flutter SDK to /opt/flutter
ENV FLUTTER_VERSION=3.22.1
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /opt/flutter

# Add Flutter to PATH for all sessions
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run Flutter pre-cache for required artifacts
RUN flutter --version

# 3. Install Android SDK and cmdline-tools
ENV ANDROID_SDK_ROOT=/opt/android-sdk-linux
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && cd /tmp \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm cmdline-tools.zip

# Accept SDK licenses before installing packages (N.B. For CI builds)
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses

# Install platform-tools, build-tools (33), platforms (33), NDK 27.0.12077973
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install \
    "platform-tools" \
    "build-tools;33.0.2" \
    "platforms;android-33" \
    "ndk;27.0.12077973"
# To install the emulator (optional for headless/CI):
# RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install "emulator"

# Set recommended permissions for VS Code/Dev Containers (avoid root-only access)
RUN chmod -R a+rX ${ANDROID_SDK_ROOT} && chown -R root:root ${ANDROID_SDK_ROOT}

# 4. Environment Variables for Flutter Android builds
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/emulator"

# 5. [OPTIONAL] VS Code Dev Containers: Install recommended extensions (for settings.json)
# (Can also be specified in .devcontainer/devcontainer.json)
# Example only:
# # RUN code --install-extension Dart-Code.flutter

# 6. Set default workdir for VS Code/Flutter CLI
WORKDIR /workspace

# 7. [OPTIONAL] Set up a non-root 'vscode' user for VS Code compatibility (uncomment if desired)
# RUN useradd -m vscode && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# USER vscode

# 8. Healthcheck (optional)
HEALTHCHECK CMD ["flutter", "--version"]

# ------------------------------------------------------------------------------
# Build Notes:
# - To use in VS Code Dev Containers, reference this Dockerfile in .devcontainer.
# - Flutter and SDKs are installed system-wide; no root permissions needed for app development.
# - For multi-user or shared scenarios: consider customizing ownership further.
# - For emulator usage, install "emulator" via sdkmanager (see above).
# ------------------------------------------------------------------------------
