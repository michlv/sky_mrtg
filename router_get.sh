#/bin/sh
CURL="curl -sk --user admin:sky http://192.168.0.1"
TIMEOUT=40

function curlGetSafe() {
  local PAGE=$1
  local TMPF="/tmp/$PAGE"
  local TMPFT="$TMPF.tmp"
  $CURL/$PAGE >$TMPFT && mv $TMPFT $TMPF
}

function getPage() {
(
  local PAGE="$1"
  local TMPF="/tmp/$PAGE"
  flock -x 200
  local GET=1
  if [ -e "$TMPF" ] ; then
    local STAT=`stat -c "%Y" $TMPF`
    local DATE=$(( `date "+%s"` - $TIMEOUT ))
    if [ "$DATE" -lt "$STAT" ] ; then
       GET=0
    fi
  fi
  if [ $GET -eq 1 ] ; then
    #Prime the auth method
    $CURL/sky_router_status.html >/dev/null
    curlGetSafe sky_router_status.html
    curlGetSafe sky_system.html
    curlGetSafe $PAGE
    $CURL/sky_logout.html >/dev/null
  fi
  cat $TMPF
) 200>/tmp/skye_get_page.lock
}

case "$1" in
        uplink-speed)
		getPage sky_router_status.html | grep -A 1 ">Line Rate - " | egrep -v -- "--|<div" | head -n 2 | sed "s/^.*'\([0-9]\+\)'.*$/\1/" | tac
		echo UNKNOWN
		echo Broadband
	;;
	gateway-ipv4)	
		getPage sky_router_status.html | grep  wanDslLinkConfig | head -1 | awk -F_ '{print $9}'
	;;
	stats-WAN|stats-LAN|stats-WLAN|stats-WLAN2|stats-WLAN5)
		WHAT=`echo $1 | sed 's/stats-//g' | sed 's/2/ (2.4/g' | sed 's/5/ (5/g'`
		getPage sky_system.html | sed 's,</tr>,</tr>\n,g' | grep ">$WHAT" | awk -F '<tr>' '{print $2}' | awk -F '<td>' '{print $4,$5,$6,$7,$8,$9}' | sed 's,</td>,,g' | sed 's,</tr>,,g'
	;;
        line-*)
                WHAT=`echo $1 | sed 's/line-//g'`
		PAGE=`getPage sky_system.html | sed 's,</tr>,</tr>\n,g' | egrep "Line Attenuation|Noise Margin"` 
	        ATT=`echo "$PAGE" | sed 's,</tr>,</tr>\n,g' | grep Attenua | sed "s/^.*\($WHAT:[0-9.]\+\).*$/\1/g" | sed "s/$WHAT://g"`
	        MARGIN=`echo "$PAGE" | sed 's,</tr>,</tr>\n,g' | grep Margin | sed "s/^.*\($WHAT:[0-9.]\+\).*$/\1/g" | sed "s/$WHAT://g"`
		awk "BEGIN {print $ATT * 1000}"
		awk "BEGIN {print $MARGIN * 1000}"
		echo "UNKNOWN"
		echo $WHAT
	;;
        wifi-channel)
                WHAT='Current Channel'
                DATA=`getPage sky_router_status.html | grep ">$WHAT" | awk -F '<span>' '{print $2}' | awk -F ' ' '{print $1,$4;}' | head -n 1`
                #$CURL/sky_system.html | grep "Current Channel"
		echo "$DATA" | cut -d ' ' -f 1
		echo "$DATA" | cut -d ' ' -f 2
		echo "UNKNOWN"
		echo "wifi-channel"
 	;; 
	*)
		echo "Unknown option"
	;;
esac
