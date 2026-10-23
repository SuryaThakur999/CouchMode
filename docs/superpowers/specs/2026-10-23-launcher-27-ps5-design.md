# Launcher 2.7 upgrade and PS5 Remote Play: design

Date: 2026-10-23. Approved by the owner in chat.

## Why

On 2026-10-23 the XNANO X5 hung on the boot logo. Logcat showed the cause: TV Home was saved as the "Always" Home app, the user was still locked (file-based encryption) at boot, TV Home is not direct-boot aware, and `ResolverActivity` retried `com.gathin.tvhome/.MainActivity` in a tight loop. Disabling TV Home and enabling the stock launcher, without an immediate reboot, recovered it. TV Home is disabled on the projector until this work ships.

## Goals

1. Run our launcher on the projector again without any chance of that loop.
2. Pick up cleanyourtv 2.7 upstream (released 2026-10-23).
3. Show the owner Projectivy Launcher next to ours, on the emulator only, and let them choose.
4. Stream the PS5 to the projector without HDMI, and use a PlayStation controller as the projector remote.

## Non-goals

- No change to NetMirror or any app the owner did not ask about.
- No 4K PS5 streaming (Remote Play tops out at 1080p).
- No change to the Sony TV in this round.

## Design

### Launcher

- Base: a fresh clone of `Gathin23/cleanyourtv` at Launcher 2.7. Our patches are re-applied from the diff of the local 2.2 working tree (`~/Projects/sony-tv-setup/cleanyourtv`): 5:3 tiles, focus scale 1.12 and easing, the LAUNCHER fallback with its `<queries>` entry, edge-colour tiles for bannerless apps, 4 columns, the interactive ClockDream fix, and the X5 theme config.
- Boot safety: the projector keeps `com.zhenhuo.elevenlauncher` enabled. TV Home is never set with `set-home-activity` and is never picked as "Always". 2.7's `stock_home_redirect` brings TV Home up when the stock home appears at boot or on Home.
- New grid tile: PS Remote Play. The dock stays Netflix, YouTube, Prime, AirPlay.
- Controller: D-pad focus, A/Cross opens, B/Circle goes back. 2.7 already lets controller keys through its key services.

### Projectivy comparison

Installed on the emulator only. The owner gets screenshots of both home screens and picks one before anything reaches the projector.

### PS5

- Sony's PS Remote Play app for Android 9 and later. The APK's signing certificate must be Sony's before install.
- The PS5 and the projector share one network. The first PSN sign-in needs internet (iPhone hotspot today).
- A DualShock 4 is fully supported on Android 11. A DualSense is tested first, since its full support arrived in Android 12.

## Testing (before the projector is touched)

On an Android 11 (API 30) emulator with file-based encryption:

1. Cold boot five times in a row with TV Home installed, the stock home enabled and `stock_home_redirect` on. Pass: `sys.boot_completed=1` each time and no `ResolverActivity` loop in logcat.
2. Redirect: pressing Home from the stock home lands on TV Home.
3. Gamepad: D-pad and A/B key events move focus, open apps and go back.
4. Screensaver starts and survives a key press.
5. Memory: TV Home PSS stays near the 2.2 figure (about 56 MB).
6. Screenshots of TV Home and Projectivy.

## Rollout

Only after every test passes: install over the projector's LAN link, enable TV Home, wait 30 s so PackageManager persists, then one monitored reboot. Rollback script (disable TV Home, enable the stock launcher, no reboot) is prepared before the install.
