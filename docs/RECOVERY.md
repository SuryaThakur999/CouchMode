# What can break, and the one command that fixes it

Every command runs from your computer on the same Wi-Fi as the device, after `adb connect <ip>:5555`.

## Avoid

- Do not uninstall tvhome or clear its data while the stock launcher is disabled: you would have no Home screen. Clearing data also drops a pushed theme.
- On an OLED TV, do not pull the plug during Panel refresh or right after a long session in standby. The panel runs its own short refresh then.
- On projectors with a vendor-signed WebView, ignore the "Android System WebView" update. It can never install; use a browser that ships its own engine (Brave, or TV Bro's Gecko build).

## Fixes

| Problem | Command |
|---|---|
| A firmware update brought apps or the old Home back | `TV_HOST=<ip> tools/maintain.sh examples/<device>/debloat.txt` |
| No Home screen (Android TV) | `adb shell pm enable com.google.android.tvlauncher` |
| No Home screen (Google TV) | `adb shell pm enable com.google.android.apps.tv.launcherx` |
| No Home screen (XNANO and similar projectors) | `adb shell pm enable com.zhenhuo.elevenlauncher` |
| Dock or theme reset to default | `TV_HOST=<ip> tools/maintain.sh examples/<device>/debloat.txt themes/<theme>` |
| A login or hotel Wi-Fi page will not load (ad-blocking DNS) | `adb shell settings put global private_dns_mode off` |
| Any disabled app is needed again | `adb shell pm enable <package>` |
| Undo a whole debloat list | `TV_HOST=<ip> tools/restore.sh examples/<device>/debloat.txt` |
