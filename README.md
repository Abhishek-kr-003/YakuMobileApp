# Yaku Mobile

A Flutter-based Android companion app for **Yaku**, designed to help users manage and keep track of their subscriptions from their mobile devices.

## Overview

Yaku Mobile connects to the Yaku backend API to provide a mobile interface for subscription management. It complements the Yaku browser extension and gives users access to their subscription information on Android.

## Features

- **User authentication** – Sign in and manage an authenticated session.
- **Subscription dashboard** – View subscription information and monthly spending.
- **Multi-currency support** – Display spending separately by currency, with currency-specific symbols.
- **Subscription management** – Add, update, view, and delete subscriptions.
- **Upcoming charges** – Review upcoming subscription payments.
- **Trial tracking** – View trial subscriptions and their end dates.
- **Subscription details** – Review information such as billing cycle, status, and management links.
- **Account settings** – Access app settings and sign out.

## Tech Stack

- **Flutter**
- **Dart**
- **REST API**
- **Android**
- **Material Design**

## Backend

Yaku Mobile communicates with the Yaku backend API.

API base URL:

```text
https://api-production-06d9c.up.railway.app/api/v1
```

API documentation:

[Open API Documentation](https://api-production-06d9c.up.railway.app/docs)

## Getting Started

### Prerequisites

Install the following:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) or Android SDK tools
- [Git](https://git-scm.com/downloads)

Verify your Flutter installation:

```bash
flutter doctor
```

### Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/yaku-mobile.git
cd yaku-mobile
```

### Install dependencies

```bash
flutter pub get
```

### Run the application

Pass the backend API URL using a Dart environment define:

```bash
flutter run --dart-define=YAKU_API_BASE_URL=https://api-production-06d9c.up.railway.app/api/v1
```

### Build the release APK

```bash
flutter build apk --release --dart-define=YAKU_API_BASE_URL=https://api-production-06d9c.up.railway.app/api/v1
```

The generated APK is located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Configuration

The application reads its API base URL through the `YAKU_API_BASE_URL` compile-time environment variable.

If the variable is not supplied, the API is not considered configured.

Example:

```bash
flutter run --dart-define=YAKU_API_BASE_URL=https://api-production-06d9c.up.railway.app/api/v1
```

For a different backend environment, replace the URL with the appropriate API base URL.

## Project Structure

The application source code is organized under `lib/`. Key areas include:

```text
lib/
├── config/       # Application configuration
├── controllers/  # Application state and actions
├── models/       # Data models
├── screens/      # Application screens
├── utils/        # Formatting and helper functions
└── widgets/      # Reusable UI components
```

## Development

Format the Dart code:

```bash
dart format lib
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Related Project

**Yaku** – The browser extension that works alongside Yaku Mobile to help users manage their subscriptions.

## Notes

- An active connection to the configured Yaku backend is required for API-powered functionality.
- Do not commit API secrets, private keys, signing credentials, or local environment files.
- The release APK is generated locally and is not included in the source repository by default.

## License

No license has been specified yet. All rights are reserved unless a license is added to this repository.
