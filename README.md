# Nudge – Habit & Routine Tracker with AI Nudges

A cross-platform habit and routine tracker for iOS and Android, built with **Flutter**. Nudge helps people stay committed to their daily goals with context-aware nudges, optional HealthKit/Google Fit auto-logging, and privacy-first weekly insights.

---

## ✨ Features
- 📅 **Habit creation** via templates or custom entries (boolean, count, minutes, millilitres, pages)
- 🔔 **Context-aware nudges** that consider time windows, streak history, motion/sleep signals, and quiet hours
- ✅ **Low-friction logging** with one-tap complete, snooze, or skip (with reasons)
- 🤝 **Auto-logging (opt-in)** through HealthKit and Google Fit integrations (steps, workouts, mindfulness, sleep)
- 📊 **Insights dashboard** highlighting streaks, completion heatmaps, best time windows, and simple correlations
- 🧩 **Widgets** for quick actions on iOS and Android home screens
- ⌚ **Wearable support** roadmap for Apple Watch and Wear OS companions
- 🔒 **Privacy-first** design with an on-device nudge engine, local-first storage, and opt-in sync/export
- 🆓 **Free tier** for up to five habits, with a ⭐ **Pro** upgrade unlocking unlimited habits, AI nudges, and advanced insights

---

## 📱 App Sections
- **Today:** Shows due and overdue habits with inline Complete/Snooze/Skip controls and a daily progress ring
- **Plan:** Weekly grid (Sunday–Saturday) to reorder, schedule, and edit habits
- **Insights:** Visualises streaks, completion rates, reasons for misses, and correlation-based tips
- **Settings:** Manage permissions, data export, theme, account settings, and Nudge Pro subscription

---

## 🚀 Getting Started

1. Install [Flutter](https://flutter.dev/docs/get-started/install) (version specified in `pubspec.yaml`).
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on an emulator or device:
   ```bash
   flutter run
   ```

> **Note:** iOS builds require macOS with Xcode installed. Android builds require the Android SDK and an emulator or device.

---

## 🧪 Testing & Linting

Run the automated checks before opening a pull request:

```bash
flutter analyze
flutter test
```

---

## 📄 Licensing

This project is distributed under the terms of the [MIT License](LICENSE).
