# Background audio

Podpine initializes one `PodpineAudioHandler` before the widget tree. The
handler owns `just_audio`; the UI-facing `PlayerController` sends commands to
it and listens to its `PlaybackState` and `MediaItem` streams. This keeps app,
lock-screen, notification, Bluetooth, and headset controls on the same queue.

## Platform configuration

Android declares internet, wake-lock, and media-playback foreground-service permissions,
the `audio_service` service and media-button receiver, and uses an
`AudioServiceActivity`. Android 14 and newer require the
`FOREGROUND_SERVICE_MEDIA_PLAYBACK` permission already present in the main
manifest.

iOS declares the `audio` background mode in `Runner/Info.plist`. In Xcode this
corresponds to **Signing & Capabilities → Background Modes → Audio, AirPlay,
and Picture in Picture**. The handler configures the shared audio session for
speech so interruptions and headset routing use podcast-appropriate behavior.
`just_audio` follows the platform interruption hints: transient pause events
(calls, alarms, and navigation prompts) resume only when the OS says they
should, unknown interruptions stay paused, ducking is handled by audio focus,
and unplugging headphones pauses without automatically restarting.

The UI controller observes app lifecycle changes without stopping background
audio. It flushes the projected playback position when the app becomes
inactive, hidden, paused, or detached, then refreshes its displayed position
from the audio service on resume. Position is also flushed on pause, seek,
manual queue navigation, and episode changes.

Queue auto-advance emits an idempotent completion event so each finished
episode is marked once, including the final queue item. Source errors skip to a
playable next item when possible; otherwise playback stops. Both outcomes stay
visible above the mini-player, with retry offered when playback stopped.

## Automated smoke tests

Run:

```sh
flutter test test/player_controller_test.dart
flutter test
flutter analyze
```

The focused smoke tests verify active-episode metadata and artwork, the queue
sent to the system handler, play/pause/seek/previous/next command routing, and
handler-driven now-playing changes.
The lifecycle tests also cover background/interruption position flushes,
exactly-once completion, queue advancement, and recoverable error states.

## Device smoke test

Use a real HTTPS episode on one physical iOS device and one Android device:

1. Start an episode, lock the device, and confirm audio continues.
2. Confirm title, podcast, artwork, elapsed time, and seek bar match the active
   episode.
3. Exercise play, pause, seek, 15-second rewind, and 30-second forward from the
   lock screen (and the Android notification).
4. Repeat play/pause/previous/next from a Bluetooth or wired headset; headset
   previous/next commands navigate the episode queue.
5. Advance to the next queued episode and confirm metadata and artwork update.
6. Background the app for at least two minutes, then reopen it and confirm the
   in-app player reflects the system position and active episode.
7. Start a phone call or navigation prompt. Confirm playback pauses or ducks,
   resumes only when the platform requests it, and retains its position.
8. Finish an episode and confirm the next queued episode begins once. Use an
   invalid audio URL and confirm Podpine either skips with a visible message or
   stops with a Retry action.

Simulators are useful for UI validation, but physical devices are required for
Bluetooth/headset routing and reliable background-execution coverage.
