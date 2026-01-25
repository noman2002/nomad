# Nomad V1 — Phased Task Plan (Approval Gates)

This repo is a Flutter app; the provided requirements mention React Native. This plan assumes **Flutter** and maps the same product requirements to Flutter equivalents.

## Phase 0 — Decisions + Setup (Approval Gate A)

- [x] Confirm target stack (Flutter vs React Native) and backend (Firebase yes/no)
- [x] Define V1 scope (must-have vs later): Living Map + video-first profiles + basic connect/interest + basic chat
- [x] Add app theme (colors/typography per requirements)
- [x] Add routing/navigation scaffold (bottom tabs: Map, Stories, Quests, Chats, Profile)
- [x] Add state management approach (keep simple: Provider/Riverpod/BLoC) and dependency injection (optional)
- [x] Create core models (User, ProfileVideo, RouteSegment, Quest, Message, Conversation)
- [x] Create mock repositories (in-memory) for rapid UI build
- [ ] CI/dev commands documented (run, format, analyze, test)

**Deliverable for approval A:** App boots with themed shell + bottom navigation + stub screens + mock data layer.

## Phase 1 — Onboarding (Approval Gate B)

Screens (5-step flow):

- [x] Welcome screen (animated van + Get Started)
- [x] Video intro capture (15–60s) + retake + name overlay
- [x] Basic info form (name/age/gender/van type/solo or with/looking for)
- [x] Vibe selection (activities x5, travel style, work situation)
- [x] Invite code (enter or request)
- [x] Location permission (foreground + background where supported)
- [ ] Persist onboarding state locally (until backend is connected)

**Deliverable for approval B:** Complete onboarding flow ends at Home (Map) with user profile stored locally.

## Phase 2 — Living Map (Home) (Approval Gate C)

- [x] Map rendering (Google Maps / Mapbox equivalent in Flutter)
- [x] Current location dot + pulsing animation
- [x] Nearby nomads as colored markers (red dating, green friends, yellow both)
- [ ] Clustering behavior (if needed for performance)
- [x] Tap marker → bottom sheet opens
- [x] Bottom sheet: auto-play looping 15s intro video + name/age/distance + 3 tags
- [x] Actions: Connect (friends) / Interested (dating)
- [x] Swipe up → Full profile screen
- [ ] Filter control (Dating/Friends/Both)
- [x] “Discover Nearby” CTA (refresh/search area)

**Deliverable for approval C:** Interactive map with mock nomads; tapping plays video in bottom sheet; connect/interest updates local state.

## Phase 3 — Full Profile + Matching (Approval Gate D)

- [x] Full profile view: video header loop + about + van details + photos carousel + vibe tags
- [x] Route preview mini-map (last 30 days + next 2 weeks) using mock polylines
- [x] Mutual connections placeholder
- [x] Matching logic (mutual interest → match created)
- [ ] Notifications placeholder hooks (UI only until Firebase/FCM)

**Deliverable for approval D:** Full profile UX done; mutual “Interested” produces a match in local state.

## Phase 4 — Stories Feed (Approval Gate E)

- [x] Vertical video feed (For You / Nearby / On Your Route / etc.)
- [x] Like, comment (basic), See on map, Share (basic)
- [x] Swipe up to full profile
- [x] Double-tap to like
- [x] Upload flow placeholder (local file) until Storage integration

**Deliverable for approval E:** TikTok-style feed works with mock/local videos + interactions.

## Phase 5 — Quests + Adventure Score (Approval Gate F)

- [x] Adventure Score + level calculation (Explorer → Legend)
- [x] Quest board UI (active quests, daily challenge)
- [x] Points engine (miles, locations, connections) using mock metrics
- [x] Level-up animation
- [x] Leaderboard (mock)

**Deliverable for approval F:** Quest board functional with computed score/levels and animations.

## Phase 6 — Chats (Approval Gate G)

- [x] Conversation list + unread badges
- [x] 1:1 chat screen (text)
- [x] “Coffee Ping” quick action
- [x] Share location / route (UI + payload model)
- [x] Media (photo/video) placeholder hooks

**Deliverable for approval G:** End-to-end local chat UX between matched users.

## Phase 7 — Firebase Backend Integration (Approval Gate H)

- [x] Firebase project setup (iOS/Android) + config files
- [x] Auth (phone auth per requirements or alternative if you prefer)
- [ ] Firestore schema + security rules (invite-only)
- [ ] Storage for profile/stories videos + thumbnails
- [ ] Real-time updates for map dots + stories feed
- [ ] Cloud Functions for matching + notifications
- [ ] FCM push notifications (matches/messages)

**Deliverable for approval H:** Real backend: sign-in, upload video, map + feed populated from Firestore, chat real-time.

## Phase 8 — Monetization (RevenueCat) + Gating (Approval Gate I)

- [ ] RevenueCat SDK integration
- [ ] Paywall screens + restore purchases
- [ ] Feature flags + gating (premium quests, spotlight, etc.)
- [ ] One-time purchases placeholders

**Deliverable for approval I:** Purchases flow integrated with gated features.

## Phase 9 — Polish + Release Prep (Approval Gate J)

- [ ] Loading/error states across app
- [ ] Performance pass (video, map markers)
- [ ] Accessibility + haptics
- [ ] Crash/analytics (optional)
- [ ] App icons/splash + store metadata
- [ ] QA checklist + smoke tests

**Deliverable for approval J:** Demo-ready build.

---

## Open Questions (need answers before Phase 0/1)

1. Confirm: do you want to build this in **Flutter** (current repo) or switch to **React Native** as the requirements list?
2. Backend: should we integrate **Firebase** now (Phase 7) or start with **mock/local data** first for fast UI approvals?
3. Auth: phone-number login required for V1, or can we start with anonymous/email for speed?
4. Map provider preference: Google Maps vs Mapbox?
