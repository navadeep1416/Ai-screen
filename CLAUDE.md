# 🤖 CLAUDE.md — Nava Screen AI

> This file gives Claude full context about the Nava Screen AI project.
> Paste this at the start of any new conversation to instantly restore context.

---

## 👤 Developer

- **Name:** Navadeep
- **Location:** Hyderabad, Telangana, India
- **Role:** Full-Stack Developer
- **Skills:** Flutter, React Native, Node.js, Python, Firebase, AI API integration

---

## 📱 Project: Nava Screen AI

### What It Is
An Android floating AI conversation assistant that appears **on top of any app**
(Instagram, WhatsApp, Telegram, Snapchat). It reads the visible screen text using
OCR, analyzes the conversation mood and relationship context, then suggests smart
replies in real time inside a draggable floating popup.

### Core Tagline
> *"thinks like a friend, replies like you"*

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Android) |
| Floating Overlay | `flutter_overlay_window` plugin |
| Screen Capture | Android `MediaProjection` API |
| OCR | Google ML Kit Text Recognition |
| Backend | Node.js + Express |
| Database | Firebase Firestore |
| Auth | Firebase Authentication |
| AI (Text) | Groq API — Llama 3 / Gemma / Mixtral |
| AI (Vision) | Gemini Vision API |
| Notifications | Firebase Cloud Messaging (FCM) |

---

## 🔄 Architecture Flow

```
User Screen
    ↓
MediaProjection (screen capture every 2-3 sec)
    ↓
Google ML Kit OCR (extract text)
    ↓
Node.js + Express Backend
POST /analyze { text, mode, userId }
    ↓
Groq API / Gemini Vision API (AI analysis)
    ↓
Firebase Firestore (write replies + analysis)
    ↓
Flutter Firestore .snapshots() listener
    ↓
Floating Popup updates in real time ✅
```

---

## 💡 11 Relationship Modes

| # | Mode | Emoji | Vibe |
|---|---|---|---|
| 1 | Love | ❤️ | Warm, romantic, deeply engaged |
| 2 | OneSide | 🥺 | Subtle hints, trying to impress |
| 3 | Friend | 😂 | Casual, funny, relaxed |
| 4 | Fight | ⚔️ | De-escalating, calm, firm |
| 5 | Enemy | 😤 | Savage, sharp, cold |
| 6 | Stranger | 👋 | Polite, curious, safe openers |
| 7 | Male Friend | 🤜 | Bro energy, banter, direct |
| 8 | Female Frnd | 💅 | Supportive, expressive, emotional |
| 9 | Crush | 💖 | Playful, flirty, mysterious |
| 10 | Best Friend | 🔥 | Brutally honest, inside jokes |
| 11 | Bestie | 👑 | Deep comfort, no filter |

---

## 🤖 AI Features

### Reply Generation
- 3 smart reply suggestions per analysis
- Reply styles: Funny / Flirty / Emotional / Savage / Mysterious / Playful / Tease

### Analysis Features
- Mood detection
- Interest level (% score)
- Energy level (x/10)
- Dry text detection
- Flirting detection
- Conversation health analysis
- Emotional energy detection
- Reply time suggestion

### Vision Features (Gemini)
- Reel / story understanding
- Screenshot understanding
- Meme analysis

---

## 📲 Floating Popup Features

- Draggable anywhere on screen
- Always-on-top overlay
- Minimize to floating bubble
- Resize (Small / Medium / Large)
- Edge snapping
- 4 size modes:
  - **Minimised** — floating bubble with sparkle icon
  - **Small** — compact card (mode + match % + message)
  - **Medium** — expanded card with tone tags + replies
  - **Large** — full assistant view

---

## 🖥️ App Screens

| Screen | Status |
|---|---|
| Splash Screen | ✅ UI done (Stitch) |
| Onboarding Slide 1 | ✅ UI done |
| Onboarding Slide 2 | ✅ UI done |
| Onboarding Slide 3 | ✅ UI done |
| Permission Setup | ✅ UI done |
| Home Dashboard | ✅ UI done |
| History | ✅ UI done |
| Settings | ✅ UI done |
| Profile | ✅ UI done |
| Floating Popup | ✅ UI designed (reference image) |
| Flutter Conversion | 🔲 Not started |
| Backend API | 🔲 Not started |
| Firebase Integration | 🔲 Not started |
| Groq AI Integration | 🔲 Not started |

---

## 🗄️ Firebase Firestore Schema

```
users/
  {userId}/
    name: "Navadeep"
    email: "..."
    createdAt: timestamp
    defaultMode: "Crush"
    favMode: "Crush"
    totalSessions: 1200
    totalReplies: 845

    sessions/
      {sessionId}/
        timestamp: ...
        appDetected: "Instagram"
        mode: "Crush"
        ocrText: "That reel was soooo true..."
        analysis/
          detectedMode: "Crush"
          matchPercent: 82
          interestLevel: 82
          energyLevel: 7.5
          replyTime: "Medium (2m-5m)"
          emotions: ["Playful", "Curious", "Flirty"]
          insights: ["She replied quickly", "Using emojis"]
          aiAdvice: "Keep it playful and confident"
        replies/
          [
            { style: "Playful", text: "Trueee 😏 But you watching..." },
            { style: "Flirty",  text: "Ohooo someone's triggered 🤭" },
            { style: "Tease",   text: "I swearrr That reel + your reaction..." }
          ]
        selectedReply: "Playful"

settings/
  {userId}/
    defaultMode: "Balanced"
    replyStyle: "Concise"
    language: "English"
    popupSize: "Medium"
    edgeSnapping: true
    autoMinimize: false
    popupPosition: "Bottom Right"
    saveHistory: true
    autoClearDays: 30
    theme: "Dark Neon"
    accentColor: "#8b5cf6"
```

---

## 🌐 Backend API Routes (Node.js + Express)

```
POST   /api/analyze          → OCR text + mode → AI analysis + replies
POST   /api/vision           → screenshot → Gemini Vision analysis
GET    /api/history/:userId  → fetch session history
POST   /api/session          → save session to Firestore
GET    /api/settings/:userId → get user settings
PUT    /api/settings/:userId → update user settings
POST   /api/auth/register    → create user
POST   /api/auth/login       → login user
```

---

## 📦 Flutter Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Overlay & Screen
  flutter_overlay_window: ^0.4.0

  # Firebase
  firebase_core: ^2.0.0
  firebase_auth: ^4.0.0
  cloud_firestore: ^4.0.0
  firebase_messaging: ^14.0.0

  # OCR
  google_mlkit_text_recognition: ^0.11.0

  # HTTP
  http: ^1.0.0
  dio: ^5.0.0

  # UI
  flutter_animate: ^4.0.0
  glassmorphism: ^3.0.0
  lottie: ^2.0.0

  # Storage
  shared_preferences: ^2.0.0
  flutter_secure_storage: ^8.0.0
```

---

## 🎨 Design System

### Colors
```dart
// Core
background:     #0d0d1a
surface:        #120d1f
card:           #1a1030
border:         #2a1f45

// Neon Accents
purple:         #8b5cf6
pink:           #ec4899
cyan:           #06b6d4
green:          #10b981

// Text
textPrimary:    #ffffff
textSecondary:  #a0a0b0
textMuted:      #6b6b80
```

### Typography
```dart
fontFamily: 'Inter' or system default
headingLarge:  28px bold white
headingMed:    20px bold white
bodyText:      14px regular white/grey
caption:       12px regular muted
```

---

## ⚡ Real-Time Data Strategy

```dart
// Battery-efficient screen polling
String previousText = '';

Timer.periodic(Duration(seconds: 3), (timer) async {
  String newText = await captureAndOCR();
  if (newText != previousText && newText.isNotEmpty) {
    previousText = newText;
    await sendToBackend(newText);
  }
});

// Firestore real-time listener
FirebaseFirestore.instance
  .collection('sessions')
  .doc(userId)
  .snapshots()
  .listen((snapshot) {
    updateFloatingPopup(snapshot.data());
  });
```

---

## 🔐 Android Permissions Required

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

---

## 🗺️ Build Order (Recommended)

```
Phase 1 — Foundation
  ✅ UI design complete (Google Stitch)
  🔲 Flutter project setup
  🔲 Firebase project setup
  🔲 Firestore schema creation

Phase 2 — Screens
  🔲 Splash + Onboarding
  🔲 Permission Setup screen
  🔲 Home Dashboard
  🔲 History + Settings + Profile

Phase 3 — Core Feature
  🔲 flutter_overlay_window setup
  🔲 Floating popup widget
  🔲 Bubble mode + resize + edge snap

Phase 4 — AI Pipeline
  🔲 MediaProjection screen capture
  🔲 Google ML Kit OCR
  🔲 Node.js backend + Groq API
  🔲 Gemini Vision for reels/screenshots

Phase 5 — Real-Time
  🔲 Firestore listeners
  🔲 Popup auto-update
  🔲 History saving

Phase 6 — Polish
  🔲 Animations (flutter_animate)
  🔲 FCM notifications
  🔲 Settings persistence
  🔲 APK build + testing
```

---

## 📝 Notes for Claude

- Always use **Flutter** (not React Native) for this project
- Backend is **Node.js + Express** (not Python)
- Database is **Firebase Firestore** (not SQL)
- AI is **Groq API** for text, **Gemini Vision** for images
- The floating popup uses **flutter_overlay_window** plugin
- Screen reading uses Android **MediaProjection** API
- User **manually selects** replies — no auto-sending ever
- Design style is **dark neon cyberpunk glassmorphism**
- Primary colors: purple `#8b5cf6` and pink `#ec4899`
- This is an **Android-only** app (no iOS needed)

---

## 🚨 Critical Instruction — Google Stitch UI

> When Navadeep gives Google Stitch UI images or HTML code:
>
> - ❌ **DO NOT change any UI** — no colors, no layout, no classes, no structure
> - ✅ **ONLY wire in real-time data** — Firebase Firestore listeners + Groq API calls
> - ✅ Keep exact same Tailwind classes, element structure, and design from Stitch
> - ✅ Just replace hardcoded/mock data with live Firebase + Groq AI data
> - ✅ The output HTML must look **pixel-identical** to the Stitch screenshot

---

*Last updated: May 2026 | By Navadeep | Hyderabad, India*
