#!/bin/bash

# Deploy Firebase Firestore and Storage rules
# Usage: ./scripts/deploy-rules.sh

set -e

echo "🚀 Deploying Firebase rules..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Deploy Firestore rules
echo "📊 Deploying Firestore rules..."
firebase deploy --only firestore:rules

# Deploy Storage rules
echo "💾 Deploying Storage rules..."
firebase deploy --only storage:rules

echo "✅ All rules deployed successfully!"
echo ""
echo "You can view your rules in the Firebase Console:"
echo "  Firestore: https://console.firebase.google.com/project/nomad-7059f/firestore/rules"
echo "  Storage: https://console.firebase.google.com/project/nomad-7059f/storage/rules"
