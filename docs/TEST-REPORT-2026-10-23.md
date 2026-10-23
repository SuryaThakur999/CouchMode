# Test report: Launcher 2.7 for the XNANO X5, 2026-10-23

Emulator: Android 11 (API 30), `default` arm64 image, file-based encryption, no leanback feature (same class of build as the X5). Stock home stand-in: Launcher3 (partially direct-boot aware).

| Check | Result |
|---|---|
| Old 2.2 build set as preferred Home, cold boot | Booted. The emulator has one FallbackHome, the X5 has two, so the X5 loop does not reproduce here. Kept as a regression guard. |
| 2.7 build, stock launcher stays default, HomeKeyService on, 5 cold boots (run twice) | 10/10 boots completed, 0 ResolverActivity loop lines, TV Home on top each time |
| Home key from Settings | Lands on TV Home in about 0.3 s, no chooser |
| Controller keys | BUTTON_A opens the focused app, BUTTON_B returns |
| Screensaver (ClockDream) | Starts, closes on a key press |
| Memory, TV Home | 24 MB PSS (2.2 measured about 56 MB on the TVs) |
| Phone-only apps in the grid | Bug found: 2.7's library filter hid them. Fixed by counting fallback apps as library apps. |
| Rollout script rehearsal, starting from TV Home disabled | Pass twice: install, one reboot, boot completed, 0 loops, Home key lands on TV Home |
| Projectivy 4.72 (signed CN=Despesse Mickael) | Runs; 82 MB PSS; asks to become the default Home on first start. Not chosen. |

Known gap: right after install, the first Home press still shows the stock home until the accessibility service binds; the rollout's single reboot covers it.
