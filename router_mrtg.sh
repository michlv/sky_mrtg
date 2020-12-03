#!/bin/sh

WHAT="$1"

dir=$(cd $(dirname "$0"); pwd)
exe=$(basename "$0")
exef=$dir/$exe

bps=`echo $WHAT | grep bps | wc -l`
ASKFOR=`echo $WHAT | cut -d "-" -f 1`

STATS=`$dir/router_get.sh stats-$ASKFOR`

IN_idx=2
OUT_idx=1

if [ $bps -gt 0 ] ; then
	IN_idx=5
	OUT_idx=4
fi

ST_IN="UNKNOWN"
ST_OUT="UNKNOWN"
ST_UPTIME="UNKNOWN"
ST_NAME="$WHAT"

if [ -n "$STATS" ] ; then
	ST_IN=`echo $STATS | cut -d " " -f $IN_idx`
	ST_OUT=`echo $STATS | cut -d " " -f $OUT_idx`
	ST_UPTIME=`echo $STATS | cut -d " " -f 6`
fi

echo $ST_IN
echo $ST_OUT
echo $ST_UPTIME
echo $ST_NAME
