#!/bin/zsh
# Usage: emu-boot-test.sh <serial> [runs]
# Cold-boots the device and fails if a boot does not complete within 180 s, or if logcat shows the
# ResolverActivity HOME loop that froze the XNANO X5 on 2026-10-23.
S=$1; N=${2:-5}; fail=0
for r in $(seq 1 $N); do
  adb -s $S reboot; sleep 5; timeout 120 adb -s $S wait-for-device
  ok=0
  for t in $(seq 1 90); do
    [ "$(adb -s $S shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ] && { ok=1; break; }
    sleep 2
  done
  sleep 8
  loops=$(adb -s $S logcat -d 2>/dev/null | grep -c 'Unable to find explicit activity class {com.gathin.tvhome')
  top=$(adb -s $S shell dumpsys activity activities 2>/dev/null | grep -m1 mResumedActivity | sed -E 's/.* u0 ([^ ]+).*/\1/')
  echo "run $r boot=$ok resolver_loops=$loops top=$top"
  { [ $ok = 1 ] && [ $loops -lt 3 ]; } || fail=1
  sleep 35
done
exit $fail
