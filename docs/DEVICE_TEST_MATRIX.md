# Physical-device release matrix

Complete this matrix against the exact signed release candidate. Record device,
OS, build number, tester, date, result, and evidence link for every row. A failure
blocks rollout until it is fixed or explicitly waived by the release owner.

## Required devices

| Lane | Minimum coverage |
| --- | --- |
| Android low | Oldest supported Android version, 3–4 GB RAM, limited free storage |
| Android current | Current Android version on a Pixel or equivalent reference device |
| Android OEM | Current Samsung device with battery optimization enabled |
| iPhone old | Oldest supported iOS version on the oldest supported iPhone class |
| iPhone current | Current iOS version on a current iPhone |
| Tablet | One physical iPad or Android tablet before a major release |

## Test cases

| Area | Procedure | Expected result | Required lanes |
| --- | --- | --- | --- |
| Playback | Stream an episode, seek backward/forward, change speed, pause, resume, and play through the episode boundary with the screen locked. | Position and controls stay accurate; the next item starts once; progress persists after relaunch. | All phone lanes |
| Audio interruption | While playing, receive a call/alarm, unplug a headset, connect/disconnect Bluetooth, and start audio in another app. | Podpine pauses or ducks appropriately, never overlaps another player, and resumes only when the platform grants focus. | Android current/OEM, both iPhones |
| Manual download | Start on Wi-Fi, background the app, terminate/relaunch, pause/resume, and complete playback from the local file. | Partial bytes resume without corruption; completed media plays with no network; state and storage totals are correct. | Android low/current, both iPhones |
| Download failure | Exhaust storage, revoke network mid-transfer, return HTTP 4xx/5xx from a test feed, then retry. | The app stays responsive, shows a safe actionable error, preserves valid partial data, and retries automatic jobs with backoff. | Android low, iPhone old |
| Offline | Download two episodes, enable airplane mode, cold-start, browse cached content, reorder the queue, play, seek, and complete one episode. | Cached UI and downloaded playback work; mutations remain queued and reconcile once online without losing local intent. | Android current, iPhone current |
| Sync conflict | Make different queue and playback changes on two physical devices, reconnect in opposite order, and refresh twice. | No duplicates or completed-state regression; both devices converge to the server-supported ordering and position rules. | Android current + iPhone current pair |
| Upgrade | Install a retained production build with subscriptions, queue, inbox, preferences, pending sync work, and partial/completed downloads. Upgrade in place to the candidate. | Launch succeeds; all records, preferences, queue order, playback position, and download files remain valid. No unexpected resync deletes data. | Every phone lane |
| Background work | Enable automatic downloads, background the app under battery saver, charging, Wi-Fi, and cellular conditions. | Platform constraints are honored; jobs do not loop; foreground state reflects completed background work. | Android OEM, iPhone current |
| Diagnostics privacy | Trigger a controlled sync failure, download failure, and test crash using non-production fixture data. Inspect the Sentry event. | Stack traces are symbolicated; only allowlisted sync/download fields appear; no URL, token, user ID, title, feed, file path, or request body is present. | Android current, iPhone current |

## Release sign-off

- Candidate version/build:
- Commit/tag:
- Android tester and date:
- iOS tester and date:
- Tablet tester and date (if required):
- CI run:
- Evidence folder:
- Open defects or waivers:
- Release owner approval:
