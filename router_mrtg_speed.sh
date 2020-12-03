#!/bin/sh

WHAT="$1"

dir=$(cd $(dirname "$0"); pwd)
exe=$(basename "$0")
exef=$dir/$exe

STATS=`$dir/router_get.sh uplink-speed`

IN_idx=1
OUT_idx=2

ST_IN="UNKNOWN"
ST_OUT="UNKNOWN"
ST_UPTIME="UNKNOWN"
ST_NAME="Broadband"

if [ -n "$STATS" ] ; then
	ST_IN=`echo $STATS | cut -d " " -f $IN_idx`
	ST_OUT=`echo $STATS | cut -d " " -f $OUT_idx`
	ST_IN=$(( ($ST_IN * 1000) / 8 ))
	ST_OUT=$(( ($ST_OUT * 1000) / 8 ))
fi

echo $ST_IN
echo $ST_OUT
echo $ST_UPTIME
echo $ST_NAME
