#!/bin/sh

WHAT="$1"

dir=$(cd $(dirname "$0"); pwd)
exe=$(basename "$0")
exef=$dir/$exe

STATS=`$dir/router_get.sh stats-WAN`

UPTIME_idx=6

ST_IN="UNKNOWN"
ST_OUT="UNKNOWN"
ST_UPTIME="UNKNOWN"
ST_NAME="Broadband"

if [ -n "$STATS" ] ; then
	UPTIME=`echo $STATS | cut -d " " -f $UPTIME_idx`
	ST_IN=`echo $UPTIME | awk -F: '{print $1*3600+$2*60+$3;}'`
	if [ $ST_IN -gt $(( 12 * 3600 )) ] ; then
		ST_IN=$(( 3 * 3600 ))
	elif [ $ST_IN -gt 3600 ] ; then
		ST_IN=3600
	elif [ $ST_IN -gt 600 ] ; then
		ST_IN=600
	fi
	ST_UPTIME=$UPTIME
fi

echo $ST_IN
echo $ST_OUT
echo $ST_UPTIME
echo $ST_NAME
