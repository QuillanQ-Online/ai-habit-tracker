# Onboarding Wizard Integration Guide

This wizard is exposed at `/onboarding` and is guarded by `OnboardingService`. The
screen orchestrates a Riverpod `OnboardingController` that maintains state, performs
step validation, and persists progress via `OnboardingStorage`.

## Wiring the Guard

1. Ensure `OnboardingService.isComplete` is checked from your global `GoRouter`
   redirect (already wired in `app_router.dart`).
2. The route supports an optional `next` query parameter. When provided, completion
   will redirect to that absolute path instead of the default `/today`.

## Persistence Hooks

- `OnboardingStorage` currently uses an in-memory key-value implementation. Replace
  `InMemoryKeyValueStore` with a platform store (e.g. `SharedPreferences`) by
  providing a different implementation via the `onboardingStorageProvider` override.
- State is serialised to JSON after every mutation to keep resume behaviour robust.

## Permission Prompts

- The notification and health steps call `_showPermissionPrompt`, which is a UI
  stub that simulates the OS sheet. Replace these handlers with real integrations
  (e.g. `FirebaseMessaging`, `HealthKit`) and pipe the resulting boolean into
  `setNotificationsResult` and `setHealthResult` respectively.
- When permissions are denied the controller still allows progress and emits
  telemetry so the Settings screen can surface follow-up CTAs.

## Analytics

Telemetry events are sent through `TelemetryService` (stub). Replace that provider
with your analytics stack to receive the following events:

- `onboarding_step_viewed` – payload includes `step` name.
- `onboarding_template_selected` – template toggles.
- `onboarding_windows_saved` – emitted for target and window edits.
- `permission_request` – `type` and `result` (granted/denied).
- `onboarding_completed` – includes `count` of selected habits.

## Testing

Widget tests cover core flows (see `test/features/onboarding`). When adding
features ensure new behaviour is represented either with widget tests or
controller unit tests.
