# ChatOn

[![Flutter Version](https://img.shields.io/badge/flutter-3.0%2B-blue)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/<your-username>/ChatOn/flutter_ci.yml?branch=main)](https://github.com/<your-username>/ChatOn/actions)

A sleek and user-friendly chat app built with Flutter and Firebase. ChatOn offers seamless onboarding, real‑time messaging, intuitive user search, profile management, and message controls — all wrapped in a polished UI to help you stay connected effortlessly.





## 🌐 Table of Contents

1. [Features](#-features)
2. [Demo](#-demo)
3. [Tech Stack](#-tech-stack)
4. [Prerequisites](#-prerequisites)
5. [Installation](#-installation)
6. [Firebase Setup](#-firebase-setup)
7. [Running the App](#-running-the-app)
8. [Project Structure](#-project-structure)
9. [Configuration](#-configuration)
10. [Contributing](#-contributing)
11. [License](#-license)


## 🔍 Features

* **Splash Screen**: Branded loading experience on launch.
* **Authentication**: Firebase Email/Password sign‑up, sign‑in & sign‑out.
* **User Search**: Find friends by username, handle or email.
* **Chat Management**:

  * One‑to‑one real‑time messaging
  * Search existing chat threads
  * Delete individual messages
* **User Management**:

  * View and update profile (display name, avatar, status)
  * Next‑screen user details within chat
* **Theming & UX**: Smooth transitions, consistent styling, light/dark support



## 🎬 Demo

<img src="https://github.com/user-attachments/assets/131d3af6-2484-473d-9351-4cad77ee18dd/1000222320" width="300">
<br>
<img src="https://github.com/user-attachments/assets/718e4739-70c7-4b82-8c30-d77983892f9b/1000222321" width="300">
<br>
<img src="https://github.com/user-attachments/assets/f3a62244-a120-4d17-9b4c-326e6bd3202a/1000222310" width="300">
<br>
<img src="https://github.com/user-attachments/assets/5a5db4d6-3e58-45bb-95b0-0b49dafb9d7f/1000222311" width="300">
<br>
<img src="https://github.com/user-attachments/assets/ff9329fe-dc53-44af-a8b4-2ee45aedc686/1000222313" width="300">
<br>
<img src="https://github.com/user-attachments/assets/92fc087b-71b8-4989-92d4-52bb792d43fb/1000222312" width="300">
<br>
<img src="https://github.com/user-attachments/assets/c069486d-bdbb-4b85-8987-3ee817611e22/1000222317" width="300">




## 🛠 Tech Stack

| Component        | Technology                          |
| ---------------- | ----------------------------------- |
| App Framework    | Flutter (Dart)                      |
| Backend Services | Firebase Authentication & Firestore |
| Storage          | Firebase Storage                    |
| CI / CD          | GitHub Actions                      |



## ⚙️ Prerequisites

* Flutter SDK ≥ 3.0
* Dart ≥ 2.17
* Android Studio or Xcode (for iOS)
* VS Code (optional, with Flutter extensions)



## 🚀 Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/<your-username>/ChatOn.git
   cd ChatOn
   ```
2. **Install dependencies**

   ```bash
   flutter pub get
   ```


## 🔗 Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Add Android & iOS apps:

   * Download `google-services.json` → place in `android/app/`
   * Download `GoogleService-Info.plist` → place in `ios/Runner/`
3. Enable Authentication providers:

   * Email/Password
   * Google Sign-In
4. Create Firestore collections:

   * `users`
   * `chats`
   * `messages` (sub-collection under each chat)



## ▶️ Running the App

```bash
# Run on connected device or simulatorlutter run

# Build release APKlutter build apk --release
```



## 📁 Project Structure

```
lib/
├─ main.dart             # Entry point & route setup
├─ services/             # Firebase wrappers (auth, user)
│  ├ auth_service.dart
│  └ user_service.dart
├─ models/               # Data classes (User, Chat, Message)
├─ controllers/          # Business logic & state controllers
├─ screens/              # UI screens (Login, ChatList, ChatView, Profile)
└─ widgets/              # Reusable components
```

  

## ⚙️ Configuration

* Manage secrets & environment variables via flavor or `.env` files.
* Refer to `docs/CONFIGURATION.md` for detailed setup.



## 🤝 Contributing

1. Fork this repo
2. Create a branch: `git checkout -b feature/<FeatureName>`
3. Commit changes: `git commit -m 'Add <FeatureName>'`
4. Push branch: `git push origin feature/<FeatureName>`
5. Open a Pull Request

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for code standards and testing guidelines.

  


