#!/bin/bash

#set -x
outputdir=/var/cores/px-collectl-data

declare -i cpid=0

signal_handler()
{
		echo "signal received"
		echo "killing collectl process (pid $cpid)"
		kill -INT $cpid
		sleep 2
}

trap "signal_handler; exit" SIGHUP SIGINT SIGTERM

# samples for 1 hours
# interval less than 60 seconds, does not collect process stats
interval=60
samplecount=60

fileidx=0

# max 3 hours worth of data
maxfiles=3

mkdir -p $outputdir
echo "logs will be collected at $outputdir"

while true
do
		[[ $(( fileidx % maxfiles )) == 0 ]] && let fileidx=0

		collectl -sCMDZF --memopts ps -i ${interval} -c ${samplecount} -f ${outputdir}/cc.raw -F 30 &
		cpid=$!
		echo "collectl pid $cpid"
		wait $cpid

		rm ${outputdir}/px-cctl-${fileidx}*

		filename=`cd ${outputdir}; ls cc.raw*gz`
		echo $filename
		mv ${outputdir}/${filename} ${outputdir}/px-cctl-${fileidx}.${filename}
		let fileidx++
		break
done
