# Acceptance Test Ideas

- Opening the app for the first time should redirect to `/onboarding`. Completing onboarding returns to `/today` and subsequent launches skip onboarding.
- Switch among Today → Insights → Plan → Settings and confirm that drilling into nested routes preserves state when returning to a tab.
- On Android, pressing the system back button pops the current tab stack; when at the root, the app should minimize instead of switching tabs.
- Attempting to open a pro-only route without entitlement should redirect to `/paywall` and, after upgrading, resume the original route.
- Deep link `nudge://habit/123` should display Habit Detail; malformed IDs fall back to Today with a toast.
- After simulating process death, relaunch should restore the last selected tab and its route where possible.
