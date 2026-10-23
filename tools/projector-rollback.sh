#!/bin/zsh
# Usage: projector-rollback.sh <ip>
# Puts the projector back on its stock home: TV Home disabled, stock launcher enabled. No reboot,
# because PackageManager saves these changes about 10 s later and a reboot before that loses them.
IP=$1; D=(adb -s $IP:5555 shell)
adb connect $IP:5555 >/dev/null
$D pm disable-user --user 0 com.gathin.tvhome
$D pm enable com.zhenhuo.elevenlauncher
sleep 35
echo "rolled back; disabled: $($D pm list packages -d | grep -cE 'tvhome')"
