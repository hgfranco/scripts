#!/bin/bash

source /etc/rackspace_credentials

# INITIALIZE COST TO ZERO
TOTAL_ESTIMATED=0
COST_io130=0
COST_PERF18=0
COST_PERF215=0
COST_PERF230=0
COST_2=0
COST_5=0
COST_8=0

# GET FIRST DAY OF THE MONTH AND TODAY'S DATE
TODAY=`date +"%y%m%d"`
FIRST_DAY=`date +%y%m01`

# ASSIGN SERVER TYPE TO VARIABLE
RS_SERVER_TYPE=`nova list --fields flavor | grep '|' | sort | cut -d ' ' -f4 | sed '$ d' | tr -d "[:blank:]"`

# SET SERVER TYPE TO COST
for server in $RS_SERVER_TYPE; do

	if [ "$server" == "io1-30" ]; then
		COST_io130=$(expr $COST_io130+1.11 | bc)
	elif [ "$server" == "performance1-8" ]; then
		COST_PERF18=$(expr $COST_PERF18+0.44 | bc)
	elif [ "$server" == "performance2-15" ]; then
		COST_PERF215=$(expr $COST_PERF215+0.68 | bc)
	elif [ "$server" == "performance2-30" ]; then
		COST_PERF230=$(expr $COST_PERF230+0.44 | bc)
	elif [ "$server" == "2" ]; then
		COST_2=$(expr $COST_2+0.34 | bc)
	elif [ "$server" == "5" ]; then
		COST_5=$(expr $COST_5+0.24 | bc)
	elif [ "$server" == "8" ]; then
		COST_8=$(expr $COST_8+1.32 | bc)
	fi

done

# ADD ALL DAILY COST
DAILY_COST=$(expr $COST_io130+$COST_PERF18+$COST_PERF215+$COST_PERF230+$COST_2+$COST_5+$COST_8 | bc)

# GET THE NUMBER OF HOURS
DIFF=$(( ($(date --date="$TODAY" +%s) - $(date --date="$FIRST_DAY" +%s) )/(60*60*24) ))

# MULTIPLY HOURS * DAILY COST * 24 HOURS TO GET TOTAL ESTIMATED COST
TOTAL_ESTIMATED=$(expr $DIFF*$DAILY_COST*24 | bc)

# OUTPUT TO GRAPHITE
echo "stats.prod.ops.billing.rs_total_estimated $TOTAL_ESTIMATED `date +%s`" | nc localhost 2003
