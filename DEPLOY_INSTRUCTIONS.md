# 🚨 IMPORTANT: Deploy Firebase Rules

## You're Getting the "unavailable" Error Because Rules Aren't Deployed Yet

The app is trying to access Firestore, but your Firebase project still has the default restrictive rules that block all access.

### Quick Fix (5 minutes)

#### Step 1: Install Firebase CLI (if you haven't already)

```bash
npm install -g firebase-tools
```

#### Step 2: Login to Firebase

```bash
firebase login
```

This will open a browser window to authenticate.

#### Step 3: Initialize Firebase in Your Project

```bash
cd "/Users/noman/Desktop/untitled folder/nomad"
firebase init
```

When prompted:
- Select: **Firestore** and **Storage**
- Choose: **Use an existing project**
- Select: **nomad-7059f** (your project)
- For Firestore rules file: Press Enter (use default `firestore.rules`)
- For Storage rules file: Press Enter (use default `storage.rules`)
- **Don't overwrite** the existing files when asked

#### Step 4: Deploy the Rules

```bash
firebase deploy --only firestore:rules,storage:rules
```

You should see:
```
✔  Deploy complete!
```

### Alternative: Deploy Manually via Firebase Console

If you can't use Firebase CLI, deploy manually:

1. **Go to Firebase Console**: https://console.firebase.google.com/project/nomad-7059f/firestore/rules

2. **Replace the rules** with the content from `firestore.rules` file:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(uid) {
      return isSignedIn() && request.auth.uid == uid;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isOwner(userId);
      
      match /likedStories/{storyId} {
        allow read, write: if isOwner(userId);
      }
    }
    
    // Locations collection
    match /locations/{locationId} {
      allow read: if isSignedIn();
      allow create, update: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow delete: if isSignedIn() && resource.data.userId == request.auth.uid;
    }
    
    // Stories collection
    match /stories/{storyId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && request.resource.data.authorId == request.auth.uid;
      allow update, delete: if isSignedIn() && resource.data.authorId == request.auth.uid;
    }
    
    // Matches collection
    match /matches/{matchId} {
      allow read: if isSignedIn() && 
        (resource.data.user1Id == request.auth.uid || resource.data.user2Id == request.auth.uid);
      allow create: if isSignedIn() && 
        (request.resource.data.user1Id == request.auth.uid || request.resource.data.user2Id == request.auth.uid);
      allow update, delete: if false;
    }
    
    // Conversations collection
    match /conversations/{conversationId} {
      allow read: if isSignedIn() && request.auth.uid in resource.data.memberUids;
      allow create: if isSignedIn() && request.auth.uid in request.resource.data.memberUids;
      allow update: if isSignedIn() && request.auth.uid in resource.data.memberUids;
      allow delete: if false;
      
      match /messages/{messageId} {
        allow read: if isSignedIn() && request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.memberUids;
        allow create: if isSignedIn() && 
          request.resource.data.fromUserId == request.auth.uid &&
          request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.memberUids;
        allow update, delete: if false;
      }
    }
  }
}
```

3. **Click "Publish"**

4. **Do the same for Storage rules**: https://console.firebase.google.com/project/nomad-7059f/storage/rules

Use content from `storage.rules` file.

### Verify Deployment

After deploying, you should see in Firebase Console:
- **Firestore Rules**: Shows the new rules with collection-specific permissions
- **Storage Rules**: Shows rules for profiles, stories, and vans folders

### Then Run the App Again

```bash
flutter run
```

The app should now:
1. ✅ Sign in successfully
2. ✅ Create user document in Firestore
3. ✅ Upload mock data
4. ✅ Display the living map with real data

## Troubleshooting

### Still getting "unavailable" error?

1. **Check Firebase Console** > Firestore Database > Rules
   - Make sure rules were published
   - Look for "Last edited" timestamp

2. **Check your internet connection**
   - The emulator/device needs internet access

3. **Clear app data and reinstall**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Check Firebase project ID**
   - In `firebase.json`, make sure `projectId` is `nomad-7059f`
   - In Firebase Console, verify project name

5. **Enable offline persistence** (already done, but verify):
   - Check `lib/app/firebase/firebase_bootstrap.dart`
   - Should have `persistenceEnabled: true`

## Need Help?

The error message "service is currently unavailable" is Firebase's way of saying:
- ❌ Your security rules are blocking access, OR
- ❌ There's a network connectivity issue

Since you've enabled Firestore in the console, it's most likely the rules need deployment.
