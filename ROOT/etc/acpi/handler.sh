#!/bin/sh
# Default acpi script that takes an entry for all actions

# NOTE: This is a 2.6-centric script.  If you use 2.4.x, you'll have to
#       modify it to not use /sys

minspeed=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq`
maxspeed=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`
setspeed="/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"

getuser ()
    {
     export DISPLAY=`echo $DISPLAY | cut -c -2`
     user=`who | grep " $DISPLAY" | awk '{print $1}' | tail -n1`
     export XAUTHORITY=/home/$user/.Xauthority
     eval $1=$user
}

set $*

case "$1" in
    button/power)
        #echo "PowerButton pressed!">/dev/tty5
        case "$2" in
            PBTN|PWRF)  
		logger "PowerButton pressed: $2" 
		getuser "user"
		echo $user > /dev/tty5
		su $user -c "/home/ferk/bin/shut.sh"
	        poweroff
		;;
            *)          logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/sleep)
        case "$2" in
            SLPB)  
		pm-suspend 
		;;
            *)      logger "ACPI action undefined: $2" ;;
        esac
        ;;
    ac_adapter)
        case "$2" in
            AC|ACAD|ADP0)
                case "$4" in
                    00000000)
                        echo -n $minspeed >$setspeed
                        /etc/laptop-mode/laptop-mode start
                    ;;
                    00000001)
                        echo -n $maxspeed >$setspeed
                        /etc/laptop-mode/laptop-mode stop
                    ;;
                esac
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    battery)
        case "$2" in
            BAT0)
                case "$4" in
                    00000000)   echo "offline" >/dev/tty5
                    ;;
                    00000001)   echo "online"  >/dev/tty5
                    ;;
                esac
                ;;
            CPU0)	
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/lid)
        echo "LID switched!">/dev/tty5
        ;;
    *)
        logger "ACPI group/action undefined: $1 / $2"
        ;;
esac
