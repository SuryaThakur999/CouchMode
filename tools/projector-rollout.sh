#!/bin/zsh
# Usage: projector-rollout.sh <launcher.apk> [psremoteplay.apk]
# Waits for the XNANO X5 (model rk3566_r_T) on whatever network the Mac is on, then installs TV Home 2.7
# without ever making it the preferred Home: the stock launcher stays the default and HomeKeyService
# (stock_home_redirect) forwards its home screen to TV Home. One monitored reboot; rolls back on failure.
APK=$1; PSRP=$2
L=${ROLLOUT_LOG:-/tmp/projector-rollout.log}
log(){ echo "$(date +%T) $*" | tee -a $L; }
ROLLBACK=${0:A:h}/projector-rollback.sh
SVC=com.gathin.tvhome/com.gathin.tvhome.HomeKeyService
MODEL=${MODEL:-rk3566_r_T}; STOCK=${STOCK:-com.zhenhuo.elevenlauncher}
# SERIAL=<adb serial> skips the network scan (used to rehearse on an emulator).
end=$((SECONDS+7200))
while [ $SECONDS -lt $end ]; do
  me=$(ipconfig getifaddr en0); base=${me%.*}
  [[ -z $me ]] && { sleep 5; continue; }
  if [ -n "$SERIAL" ]; then targets=$SERIAL; else targets=$(for i in $(seq 1 254); do (nc -z -G1 $base.$i 5555 2>/dev/null && echo $base.$i:5555) & done; wait); fi
  for dev in $targets; do
    ip=${dev%:*}; [ -n "$SERIAL" ] || adb connect $dev >/dev/null 2>&1; sleep 1; D=(adb -s $dev shell)
    [ "$($D getprop ro.product.model | tr -d '\r')" = "$MODEL" ] || continue
    log "projector at $ip, boot_completed=$($D getprop sys.boot_completed | tr -d '\r')"
    [ "$($D getprop sys.boot_completed | tr -d '\r')" = 1 ] || { log "not fully booted; stopping without changes"; exit 2; }
    log "stock launcher direct-boot flags: $($D dumpsys package $STOCK | grep -m1 -oE '[A-Z_]*DIRECT_BOOT_AWARE' || echo none)"
    stock=$($D cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME | grep -m1 "$STOCK/" | tr -d ' \r')
    [ -n "$stock" ] || { log "stock HOME activity not found; stopping without changes"; exit 3; }
    log "stock home: $stock"
    adb -s $dev install -r "$APK" | tee -a $L
    $D pm enable com.gathin.tvhome >> $L
    $D pm enable $STOCK >> $L
    $D cmd package set-home-activity "$stock" >> $L
    s=$($D settings get secure enabled_accessibility_services | tr -d '\r')
    case "$s" in *HomeKeyService*) ;; null|'') s=$SVC ;; *) s="$s:$SVC" ;; esac
    $D settings put secure enabled_accessibility_services "''"; $D settings put secure accessibility_enabled 0; sleep 1
    $D settings put secure enabled_accessibility_services "$s"; $D settings put secure accessibility_enabled 1
    [ -n "$PSRP" ] || PSRP=$(ls -t ~/Downloads/*[Rr]emote*[Pp]lay*.apk ~/Downloads/*playstation*.apk 2>/dev/null | head -1)
    if [ -n "$PSRP" ] && [ -f "$PSRP" ]; then
      BT=$(ls -d /opt/homebrew/share/android-commandlinetools/build-tools/* | tail -1)
      cert=$(JAVA_HOME=/opt/homebrew/opt/openjdk@17 $BT/apksigner verify --print-certs "$PSRP" 2>/dev/null | grep -m1 'certificate DN')
      log "PS Remote Play $PSRP: $cert"
      case "$cert" in *Sony*|*SONY*|*PlayStation*) adb -s $dev install -r "$PSRP" | tee -a $L ;; *) log "PS Remote Play NOT installed: signer is not Sony" ;; esac
    else log "PS Remote Play file not found; skipped"; fi
    sleep 35
    $D input keyevent KEYCODE_HOME; sleep 4
    log "after HOME: $($D dumpsys activity activities | grep -m1 mResumedActivity | sed -E 's/.* u0 ([^ ]+).*/\1/')"
    log "rebooting once"; $D reboot; sleep 20
    ok=0
    for t in $(seq 1 60); do
      [ -n "$SERIAL" ] || adb connect $dev >/dev/null 2>&1
      [ "$($D getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ] && { ok=1; break; }
      sleep 3
    done
    loops=$($D logcat -d 2>/dev/null | grep -c 'Unable to find explicit activity class {com.gathin.tvhome')
    sleep 8
    top=$($D dumpsys activity activities 2>/dev/null | grep -m1 mResumedActivity | sed -E 's/.* u0 ([^ ]+).*/\1/')
    log "boot=$ok resolver_loops=$loops top=$top"
    $D am start -a android.settings.SETTINGS >/dev/null 2>&1; sleep 3; $D input keyevent KEYCODE_HOME; sleep 4
    home=$($D dumpsys activity activities 2>/dev/null | grep -m1 mResumedActivity | sed -E 's/.* u0 ([^ ]+).*/\1/')
    log "Home key after reboot: $home"
    if [ $ok = 1 ] && [ $loops -lt 3 ] && [[ $home == com.gathin.tvhome/* ]]; then log "ROLLOUT OK"; exit 0; fi
    log "ROLLOUT FAILED, rolling back"; $ROLLBACK $ip | tee -a $L; $D reboot; exit 1
  done
  sleep 5
done
log TIMEOUT
