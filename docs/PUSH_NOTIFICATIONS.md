# Push notifications (FCM) — mobile setup

The backend side is **live in production**. Device registration, delivery, and
dead-token cleanup all work today; what's left is the Flutter app.

## What the backend already does

- `POST /v1/me/devices` — register this install's FCM token (auth required).
- `DELETE /v1/me/devices` — unregister on sign-out.
- Sends a push (alongside the existing email) on: **booking confirmed**,
  **team join request** → captain, **team request accepted** → player,
  **challenge accepted** → both captains.
- Writes every notification in the recipient's own language. Each device row
  stores a language, so a Swahili account and an English account get different
  copy from the same event — you never render text yourself, just display
  `notification.title` / `notification.body`.
- Prunes tokens Firebase reports as dead (uninstalled / rotated), so you don't
  need an explicit cleanup call beyond the sign-out `DELETE`.

## Firebase project

Ben owns the Firebase project and will hand you:

- `google-services.json` → `android/app/`
- `GoogleService-Info.plist` → `ios/Runner/`

Both are **committed to the repo** in the other PitchTZ-family apps (lastcard,
hadithizetu) — follow that convention here. Run `flutterfire configure` against
the project Ben created to generate `lib/firebase_options.dart`; do **not**
hand-copy another app's file.

APNs is configured in the Firebase console (auth key uploaded under Project
settings → Cloud Messaging). If iOS pushes silently never arrive, that upload
is the first thing to check.

## Packages

```yaml
firebase_core: ^4.5.0
firebase_messaging: 16.1.2   # pinned exactly — see note
flutter_local_notifications: ^22.0.1
```

> `firebase_messaging` 16.4.2 referenced a renamed symbol (`FirebasePlugin`)
> that no released `firebase_core_platform_interface` provided, so it failed to
> compile. lastcard pins `16.1.2` for this reason. Re-check whether upstream
> has aligned before you take the caret off — if it has, use the current
> version.

## The contract

Register after sign-in and on **every** token refresh:

```dart
await dio.post('/v1/me/devices', data: {
  'token': fcmToken,
  'platform': Platform.isIOS ? 'ios' : 'android',
  'app_version': packageInfo.version,   // optional
  // 'language' omitted → backend uses the account's own language
});
```

On sign-out:

```dart
await dio.delete('/v1/me/devices', data: {'token': fcmToken});
```

Both are **best-effort**: wrap in try/catch and swallow failures. A failed
registration must never block sign-in, and only fire it when a JWT exists —
the endpoint is authenticated.

## Notification channel

Android channel id must be **`pitchtz_alerts`** — the backend sets this on
every message, and a mismatch means notifications arrive silently with no
heads-up banner. Create it in `flutter_local_notifications` **and** declare it
as the manifest default:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="pitchtz_alerts" />
```

Also declare `POST_NOTIFICATIONS` (Android 13+) so `requestPermission()` has
something to ask for.

## Deep links — the `data.type` switch

Every push carries a `data` map whose `type` key tells you where to go:

| `type` | Other keys | Route to |
| --- | --- | --- |
| `booking_confirmed` | `booking_id`, `code` | that booking's detail |
| `team_join_request` | `team_id` | the team's requests screen (captain) |
| `team_accepted` | `team_id` | the team screen |
| `challenge_accepted` | `match_id` | the match/challenge screen |

Treat an unknown `type` as "open the app, do nothing special" — more types will
be added server-side without an app release.

## The cold-start trap

`FirebaseMessaging.instance.getInitialMessage()` can resolve **before** your
router exists. lastcard solves this by having the notification service stash a
pending `(type, data)` tuple and replay it the moment a handler is attached —
copy that behaviour or a tap that launches the app from terminated will
silently do nothing. It's the single easiest thing to get wrong here.

`lastcard`'s `lib/core/notifications/notification_service.dart` is the
reference implementation for all of the above (Riverpod + go_router, same stack
as this app should use). Copy it structurally, rename the channel to
`pitchtz_alerts`, and swap the endpoint to `/v1/me/devices`.
