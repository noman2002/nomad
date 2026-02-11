# 🚐 Nomad - Van Life Connection App

A Flutter app connecting van lifers for dating, friendship, and community through a living map with video-first profiles.

## ✨ Features

- **Living Map** - Real-time map showing nearby nomads with animated markers
- **Video-First Profiles** - 15-60 second video introductions instead of static photos
- **Stories Feed** - Vertical video feed of van life stories
- **Quest System** - Gamification with adventure scores and challenges
- **Real-time Chat** - Connect with matches and send messages
- **Route Matching** - See who's heading in your direction

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Firebase CLI (for deploying rules)
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd nomad
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### First Launch

On first launch, the app will:
1. Auto-create a test Firebase account (`test@nomad.app`)
2. Upload sample mock data to Firestore
3. Sign you in automatically

## 🔥 Firebase Setup

The app uses Firebase for:
- **Authentication** - Email/password (phone auth planned)
- **Firestore** - Real-time database for users, locations, stories, chat
- **Storage** - Video and image uploads

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed Firebase configuration.

### Deploy Firebase Rules

```bash
./scripts/deploy-rules.sh
```

Or manually:
```bash
firebase deploy --only firestore:rules,storage:rules
```

## 📁 Project Structure

```
lib/
├── app/
│   ├── firebase/
│   │   ├── auth/           # Authentication services
│   │   └── firestore/      # Firestore services & data migration
│   ├── models/             # Data models
│   ├── screens/            # UI screens (tabs, onboarding, etc.)
│   ├── state/              # State management (Provider)
│   └── util/               # Utilities
├── firebase_options.dart   # Firebase configuration
└── main.dart              # App entry point
```

## 🧪 Development

### Test Credentials

- Email: `test@nomad.app`
- Password: `test123456`

### Mock Data

Mock data is automatically populated on first launch. To manually manage:

```dart
// Upload mock data
await DataMigration.uploadMockData();

// Clear mock data
await DataMigration.clearMockData();
```

## 📋 Implementation Status

### ✅ Phase 0-6 (Complete)
- App setup and theming
- Onboarding flow
- Living map with real-time locations
- Full profile screens
- Stories feed
- Quest system and gamification
- Chat functionality

### ⚠️ Phase 7 (In Progress)
- ✅ Firebase Auth (email/password)
- ✅ Firestore schema & security rules
- ✅ Real-time data streams
- ✅ Mock data migration
- ❌ Cloud Functions (not started)
- ❌ FCM push notifications (not started)
- ❌ Video upload/download (not started)

### ❌ Phase 8-9 (Not Started)
- RevenueCat integration
- Paywall screens
- Polish & accessibility
- Performance optimization
- App icons & splash screens

See [TASKS.md](TASKS.md) for detailed task breakdown.

## 🛠️ Tech Stack

- **Framework**: Flutter 3.8+
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Maps**: flutter_map with OpenStreetMap
- **Video**: video_player
- **Payments**: RevenueCat (planned)

## 🔐 Security

- Firestore security rules enforce user permissions
- Storage rules restrict uploads to authenticated users
- All sensitive operations require authentication
- Invite-only access (planned)

## 📱 Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🤝 Contributing

This is a hackathon/prototype project. See the requirements document for the full product vision.

## 📄 License

Private project - All rights reserved

## 🎯 Next Steps

1. **Deploy Firebase rules** to production Firebase project
2. **Implement video upload** to Firebase Storage
3. **Add Cloud Functions** for matching logic
4. **Set up FCM** for push notifications
5. **Integrate RevenueCat** for monetization
6. **Polish UI/UX** and add proper error handling
7. **Implement phone authentication** for production
8. **Add invite code validation**

---

Built with ❤️ for the van life community
