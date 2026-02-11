# Firebase Setup Guide

## Overview

This app uses Firebase for authentication, Firestore for data storage, and Firebase Storage for media files.

## 🔐 Authentication

The app uses **Firebase Authentication** with email/password sign-in.

### Development Auto-Login

For development purposes, the app automatically signs in with a test account:
- **Email**: `test@nomad.app`
- **Password**: `test123456`

The account is created automatically on first launch if it doesn't exist.

### First Launch Behavior

On the first launch after authentication:
1. A user document is created in Firestore
2. Mock data (sample users, locations, stories) is automatically uploaded to Firestore
3. This only happens once per Firebase project

## 📊 Firestore Database

### Collections Structure

```
users/
  {userId}/
    - name, age, lookingFor, activities, etc.
    - User profile data
    likedStories/
      {storyId}/
        - createdAt

locations/
  {userId}/
    - userId, lat, lng, updatedAt
    - Real-time location data

stories/
  {storyId}/
    - authorId, videoUrl, caption, category, etc.

matches/
  {matchId}/
    - user1Id, user2Id, createdAt

conversations/
  {conversationId}/
    - memberUids[], lastMessageText, etc.
    messages/
      {messageId}/
        - fromUserId, text, sentAt, kind
```

### Security Rules

Security rules are defined in `firestore.rules`:
- Users can only edit their own profiles
- All authenticated users can read profiles and locations
- Users can only create/edit their own stories
- Conversations are private to participants

## 💾 Firebase Storage

### Storage Structure

```
profiles/{userId}/
  - video.mp4 (profile intro video)

stories/{storyId}/
  - video.mp4 (story video)
  - thumbnail.jpg (video thumbnail)

vans/{userId}/
  - photo1.jpg, photo2.jpg, etc. (van photos)
```

### Storage Rules

Storage rules are defined in `storage.rules`:
- Users can only upload their own profile videos and van photos
- All authenticated users can read media files
- Video size limit: 100MB
- Image size limit: 5-10MB

## 🚀 Deploying Rules

### Prerequisites

Install Firebase CLI:
```bash
npm install -g firebase-tools
```

Login to Firebase:
```bash
firebase login
```

### Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### Deploy Storage Rules

```bash
firebase deploy --only storage:rules
```

### Deploy All Rules

```bash
firebase deploy --only firestore:rules,storage:rules
```

## 🧪 Mock Data Migration

Mock data is automatically uploaded on first launch. To manually upload or clear data:

### Upload Mock Data

```dart
import 'package:nomad/app/firebase/firestore/data_migration.dart';

await DataMigration.uploadMockData();
```

### Clear Mock Data

```dart
await DataMigration.clearMockData();
```

## 🔧 Configuration Files

- `firestore.rules` - Firestore security rules
- `storage.rules` - Storage security rules
- `firebase.json` - Firebase project configuration
- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config

## 📱 Testing

### Android

Firebase is automatically configured via `google-services.json`.

### iOS

Firebase is automatically configured via `GoogleService-Info.plist`.

## 🔒 Production Considerations

Before going to production:

1. **Replace test auto-login** with proper onboarding flow
2. **Implement phone authentication** (per requirements)
3. **Add invite code validation** in security rules
4. **Enable App Check** for additional security
5. **Set up proper indexes** for Firestore queries
6. **Configure Firebase Storage CORS** if needed
7. **Add rate limiting** via App Check or Cloud Functions
8. **Review and tighten security rules** based on actual usage patterns

## 📖 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Storage Security](https://firebase.google.com/docs/storage/security)
