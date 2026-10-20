#!/usr/bin/env bash
# Weekly tune-up, and the fix after every firmware update. Firmware updates can turn disabled apps back on
# and hand Home back to the stock launcher; this puts your setup back and prints a health report.
# Nothing is uninstalled.
#
# Usage: TV_HOST=192.168.1.50 tools/maintain.sh examples/<device>/debloat.txt [themes/<theme>]
set -euo pipefail
cd "$(dirname "$0")/.."
: "${TV_HOST:?set TV_HOST to the device IP, e.g. TV_HOST=192.168.1.50 $0 examples/sony-kd65a1/debloat.txt}"
LIST="${1:?usage: maintain.sh <debloat list> [theme folder]}"
THEME="${2:-}"
export ANDROID_SERIAL="$TV_HOST:5555"

adb connect "$ANDROID_SERIAL" >/dev/null
adb get-state >/dev/null || { echo "Device not reachable at $ANDROID_SERIAL. Is it on, on the same Wi-Fi, with network debugging on?"; exit 1; }

echo "== Debloat"
enabled=$(adb shell pm list packages -e | tr -d '\r' | sed 's/package://')
for p in $(grep -vE '^\s*(#|$)' "$LIST" | sed -E 's/[[:space:]]+#.*$//'); do
  if printf '%s\n' "$enabled" | grep -qx "$p"; then
    adb shell -n pm disable-user --user 0 "$p" >/dev/null && echo "  re-disabled $p"
  fi
done

echo "== Home"
adb shell -n cmd package set-home-activity com.gathin.tvhome/.MainActivity >/dev/null && echo "  tvhome is Home"

if [ -n "$THEME" ]; then
  # Android 11+ blocks adb push into Android/data (fchown fails); streaming through the shell works.
  DIR=/sdcard/Android/data/com.gathin.tvhome/files
  adb shell -n "mkdir -p $DIR"
  adb exec-in "cat > $DIR/config.json" < "$THEME/config.json"
  [ -f "$THEME/wallpaper.jpg" ] && adb exec-in "cat > $DIR/wallpaper.jpg" < "$THEME/wallpaper.jpg"
  adb shell -n "am force-stop com.gathin.tvhome" && echo "  theme $(basename "$THEME") applied"
fi

echo "== Cache"
adb shell -n pm trim-caches 4G >/dev/null && echo "  app caches cleared"

echo "== Report"
adb shell -n cat /proc/meminfo | grep MemAvailable | awk '{printf "  free RAM %d MB\n", $2/1024}'
adb shell -n df -h /data | tail -1 | awk '{print "  storage free " $4}'
adb shell -n dumpsys wifi | grep -m1 mWifiInfo | grep -oE 'RSSI: [^,]*|Frequency: [^,]*' | sed 's/^/  /'
echo "  disabled apps: $(adb shell -n pm list packages -d | wc -l | tr -d ' ')"
