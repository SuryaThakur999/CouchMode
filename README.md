<p align="center">
  <img src="assets/readme-banner.jpg" alt="CouchMode: Claude sets up a Sony BRAVIA A1 and an XNANO X5 projector over Wi-Fi" width="100%" />
</p>

<h1 align="center">CouchMode</h1>
<p align="center"><em>paste one prompt, get a home cinema.</em></p>

<h3 align="center">A 160-inch, ad-free home cinema on your wall. Claude sets it up over Wi-Fi while you stay on the couch.</h3>

<p align="center">
  Open Claude Code, paste the prompt below, and it strips the bloat, installs an Apple TV-inspired home screen,
  fixes the quirks of cheap Android projectors and puts your PS5 on the wall. No root, no HDMI cable across the room,
  nothing uninstalled, one line to undo.
</p>

<p align="center">
  <a href="#let-claude-do-it"><img alt="Claude ready" src="https://img.shields.io/badge/Claude-ready-ff2d2d?style=for-the-badge&labelColor=0a0a0a"></a>
  <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-ff4500?style=for-the-badge&labelColor=0a0a0a"></a>
  <a href="#quick-start"><img alt="Android 8 and up" src="https://img.shields.io/badge/android-8%2B-ff2d2d?style=for-the-badge&labelColor=0a0a0a"></a>
  <a href="#ps5-on-the-wall"><img alt="PS5 over Wi-Fi" src="https://img.shields.io/badge/PS5-over%20Wi--Fi-ff4500?style=for-the-badge&labelColor=0a0a0a"></a>
  <a href="#how-it-works"><img alt="No root" src="https://img.shields.io/badge/root-not%20needed-ff2d2d?style=for-the-badge&labelColor=0a0a0a"></a>
</p>

<p align="center"><sub><a href="#what-you-get">What you get</a> · <a href="#let-claude-do-it">Let Claude do it</a> · <a href="#support-couchmode">Support</a> · <a href="#what-changed">What changed</a> · <a href="#quick-start">Quick start</a> · <a href="#projectors">Projectors</a> · <a href="#ps5-on-the-wall">PS5</a> · <a href="#the-home-screen">Home screen</a> · <a href="#netflix-light-cue">Light cue</a> · <a href="#keeping-it-fast">Keeping it fast</a> · <a href="#how-it-works">How it works</a> · <a href="#credits">Credits</a></sub></p>

---

## What you get

- **A screen as big as your wall.** Up to a 160-inch picture in Full HD (1080p) on a projector like the XNANO X5.
  How big still looks sharp depends on your projector and how dark the room is; our 400-lumen X5 looks best at around 90 inches in a dark room.
- **No ads.** The home screen shows your apps and nothing else. No banners, no "recommended for you" rows.
- **Faster and calmer.** We switched off the junk that runs in the background. Our Sony TV went from about 250 MB to about 510 MB of free memory, so it stops choking.
- **Looks like an Apple TV.** Big tiles that lift up when you move onto them, a clock and the date, a clean dock.
- **Make it yours.** Pick which apps sit in the dock, how many tiles per row and the wallpaper. No coding needed.
- **PS5 on the wall.** Play on the big screen while the PS5 stays plugged into your TV. No long HDMI cable.
- **The room goes dark when Netflix starts.** Optional: a Govee bulb flashes red and turns off.
- **Undo any time.** Nothing is deleted. One command puts everything back.

## Let Claude do it

You do not need to know what ADB is. Turn on developer options and USB debugging on the TV or projector once
(Settings, About, press Build seven times), make sure your computer is on the same Wi-Fi, then give Claude this:

```text
Clone https://github.com/SuryaThakur999/CouchMode and read README.md and docs/RECOVERY.md first.
My TV/projector is on my Wi-Fi with debugging on. Find it with `adb mdns services`, check the model,
back it up, disable the bloat from the closest list in examples/, install the launcher and set it up.
Follow the warnings in the README exactly: never disable a projector's stock launcher, wait 30 seconds
after any package change before rebooting, and ask me before adding or removing any app.
```

Claude does the clicking and the commands; you approve each step. The warnings in that prompt are there because
we hit each of those problems on a real projector, and the [recovery guide](docs/RECOVERY.md) shows how we got out.

## Support CouchMode

<p align="center">
  Your TV got its speed back for free. If that saved you an evening of fiddling (or a new TV),<br>
  a coffee keeps new device lists and projector fixes coming. Starring the repo helps the next person find it.
</p>

<p align="center">
  <a href="https://www.paypal.com/paypalme/SuryaThakur140"><img src="assets/btn-paypal.svg" alt="Buy me a coffee with PayPal" height="64"></a>
  &nbsp;
  <a href="https://github.com/SuryaThakur999/CouchMode/stargazers"><img src="assets/btn-star.svg" alt="Star CouchMode on GitHub" height="64"></a>
</p>

## What changed

Measured on two real devices before and after, with `adb shell cat /proc/meminfo`:

| Device | Free RAM before | Free RAM after | Apps disabled |
|---|---|---|---|
| Sony BRAVIA KD-65A1 (Android 9, 2 GB) | about 250 MB | about 510 MB | 32 |
| XNANO X5 projector (Android 11 tablet build, 2 GB) | about 570 MB | about 750 MB | 17 |

The home screen itself uses about 56 MB. The stock Google TV launcher it replaces used about 158 MB on the Sony.

Two honest things up front:

- **Netflix quality on most no-name projectors does not change.** Most no-name projectors ship with Widevine L3, which caps
  Netflix and other paid services at low resolution. No launcher or setting can fix that; it is in the hardware.
- **Everything is reversible.** Apps are disabled, not deleted, and every list has a matching restore command.

## Quick start

You need a computer with `adb` on the same Wi-Fi as the TV, and USB debugging switched on in the TV's
developer options. Accept the "Allow USB debugging?" prompt on the TV once.

```bash
git clone https://github.com/SuryaThakur999/CouchMode && cd CouchMode

# 1. back up, then disable the bloat for your device (or start from the closest example)
TV_HOST=192.168.1.50 tools/disable.sh examples/sony-kd65a1/debloat.txt

# 2. build and install the home screen
TV_HOST=192.168.1.50 launcher/build-and-install.sh

# undo step 1 at any time
TV_HOST=192.168.1.50 tools/restore.sh examples/sony-kd65a1/debloat.txt
```

Tested on Android 9 (Sony A1) and Android 11 (XNANO X5). There are 30+ device lists in [`examples/`](examples/) from the original project, plus two new ones:
[`sony-kd65a1`](examples/sony-kd65a1/debloat.txt) and [`xnano-x5`](examples/xnano-x5/debloat.txt).
The full walkthrough from the original project is in [docs/cleanyourtv-README.md](docs/cleanyourtv-README.md).

## Projectors

Cheap Android projectors (Rockchip, Allwinner, Amlogic boards sold as XNANO, Magcubic and others) often run a
**tablet** build of Android, not Android TV. Most launchers break on them: phone apps such as Netflix or Prime Video
have no TV entry point, so they never appear. CouchMode handles that:

- **Tablet builds detected automatically.** With no leanback feature present, the grid lists the normal app icons too.
- **Dock apps always show.** An app you pin to the dock appears even if it only has a phone launcher entry.
- **Brand tiles for phone apps.** Apps without TV artwork get a tile filled with their icon's own background colour,
  so Netflix is black with a red N and Prime is blue, instead of a small icon on grey.
- **Screensaver that stays on.** Some projectors send a stray input event the moment a screensaver starts, which closes it
  straight away. The clock screensaver now ignores those and only closes on a real remote button.
- **Themes push on Android 11+.** `adb push` into `Android/data` fails there (`fchown` is not permitted), so the tools
  stream the file through the shell instead.

**Do not disable the projector's stock launcher, and do not make CouchMode the "Always" Home app.** On the XNANO X5
both left the projector hanging on the Android logo: at boot the storage is still locked, a non-system launcher cannot
start yet, and Android retries it forever. Network ADB comes up over a LAN cable even then, which is how we recovered it
([docs/RECOVERY.md](docs/RECOVERY.md)).

The projector build avoids this completely. It is built with `-PhomeCategory=android.intent.category.DEFAULT`, so it
never registers as a Home app; the stock launcher stays the real Home, and an accessibility service sends Home presses
and boot straight to CouchMode. `tools/projector-rollout.sh` installs it with a monitored reboot and rolls back on its own
if the boot check fails.

## PS5 on the wall

Ready for GTA VI night without running an HDMI cable across the room: your PS5 stays plugged into the TV and streams to
the projector over Wi-Fi with Remote Play.

<p align="center">
  <img src="assets/ps5-fc-projector.jpg" alt="EA Sports FC streamed from a PS5 to the XNANO X5 projector" width="49%" />
  <img src="assets/ps5-nfs-projector.jpg" alt="Need for Speed Heat streamed from a PS5 to the XNANO X5 projector, with Chiaki's on-screen buttons visible" width="49%" />
</p>
<p align="center"><sub>Captured on the X5 itself while we played, PS5 streaming over a phone hotspot. The faint buttons on the right shot are Chiaki's touch overlay.</sub></p>

- **App.** Sony's PS Remote Play app may not run on no-name projectors (on the X5 it crashed in the projector's keystore
  check). The open-source Chiaki client works: register it once with your PSN account ID and the PIN from the PS5.
- **Settings that worked on the X5.** 1080p, 60 fps, H264, bitrate 15000 to 30000. Pair a DualSense in Bluetooth
  settings (hold PS and Create) and it drives the stream.
- **Honest limits.** Remote Play is compressed video and tops out at 1080p. On a phone hotspot we logged about one broken
  frame in eight, which shows up as smearing; the fix is the network, not the app. Put the PS5 and the projector on a
  router (a cable for the PS5 helps most). For a picture identical to the TV, an HDMI splitter with a 1080p output to
  the projector beats any stream.

## The home screen

The launcher is Apple TV-inspired and follows Apple's published motion guidance:

- **5:3 tiles**, the Apple TV app icon proportion, four to a row by default.
- **Focus that lifts.** The focused tile grows 1.12x and rises on a soft shadow, eases out over 200 ms and settles
  back in 150 ms. No bounce, because you press the D-pad dozens of times an hour.
- **Name under the focused tile only**, like Apple TV, so the grid stays calm.
- **OLED-safe screensaver.** A thin clock on black that moves every minute, so nothing sits still long enough to burn in.

Change the dock, columns or wallpaper without rebuilding: edit a theme in [`themes/`](themes/) and push it.
[`themes/xnano-x5`](themes/xnano-x5/config.json) is a ready example.

## Netflix light cue

[`lights/`](lights/) is a small optional app that flashes a **Govee Bluetooth bulb** Netflix red and then turns it off
when Netflix opens, so the room goes dark as the film starts.

- **No Wi-Fi, no Govee account, no pairing.** It finds the nearest Govee bulb by its Bluetooth name on first start.
- **Fast.** It holds one standing Bluetooth link; in our test on a Sony A1 the light reacted about half a second after Netflix opened.
- **Light on the TV.** About 3 MB of RAM and no CPU while idle; it only wakes when the app in front changes.

Tested with a Govee H6008 bulb from a Sony A1. The colour command differs between Govee models, so other bulbs may
need the colour mode changed in `GoveeBulb.java`. While the light cue holds the bulb, the Govee phone app cannot
control that one bulb.

```bash
cd lights && ./gradlew assembleRelease
adb install -r app/build/outputs/apk/release/app-release.apk
adb shell pm grant io.github.tvhome.lights android.permission.ACCESS_FINE_LOCATION
# add the service without switching off other accessibility services (TalkBack and similar)
cur=$(adb shell settings get secure enabled_accessibility_services | tr -d '\r')
new=io.github.tvhome.lights/io.github.tvhome.lights.LightsService
[ "$cur" = "null" ] || [ -z "$cur" ] || new="$cur:$new"
adb shell settings put secure enabled_accessibility_services "$new"
adb shell settings put secure accessibility_enabled 1
```

## Keeping it fast

Firmware updates like to switch disabled apps back on and give Home back to the stock launcher. One command puts
everything back and prints a health report (free RAM, storage, Wi-Fi band, disabled apps):

```bash
TV_HOST=192.168.1.50 tools/maintain.sh examples/sony-kd65a1/debloat.txt
TV_HOST=192.168.1.51 tools/maintain.sh examples/xnano-x5/debloat.txt themes/xnano-x5
```

If something does go wrong, [docs/RECOVERY.md](docs/RECOVERY.md) lists what to avoid and the one command that fixes
each case.

Most buffering is the network, not the TV: a 2.4 GHz link (often a phone hotspot) is the usual cause. 5 GHz Wi-Fi or a
cable helps more than any setting here.

## How it works

Android TVs and Android projectors have the same debug bridge as Android phones. With debugging allowed once, standard
tooling does the rest: back up the package list, disable telemetry, ad services and preloaded apps with
`pm disable-user`, install a launcher and make it Home, and push a theme. Nothing needs root and nothing is uninstalled.

## Credits

CouchMode builds on [**cleanyourtv**](https://github.com/Gathin23/cleanyourtv) by [Gathin](https://github.com/Gathin23):
the original debloat tools, the device lists and the launcher this project extends. If CouchMode helped, star the original too.

This fork adds projector support, the brand tiles and focus motion, the screensaver fix, the light cue, the
maintenance and recovery tools, and the Sony A1 and XNANO X5 lists.

## Disclaimer

CouchMode is an independent project. It is not affiliated with or endorsed by Apple, Sony, PlayStation, Rockstar Games, Netflix, Google, Anthropic or Govee.
Product names are used only to describe compatibility.

## License

MIT. See [LICENSE](LICENSE); the original copyright stays alongside this fork's.
