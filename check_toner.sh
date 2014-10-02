#!/bin/bash
#
#check_toner version 0.5
#
#04-10-2009, Henry Franco
#
# This Nagios plugin will check the black toner level on a printer via SNMP.
# The plugin returns warning and critical status when the toner
# drops below $CRIT AND $WARN.


if [ $# -lt 1 ]; then
        echo "Usage: ./check_toner PRINTER_NAME"
        exit 127
fi

HOST=$1
INK="Black ink available:"
CRIT=5
WARN=10
STATUS=0
nagios_plug_dir=/etc/nagios/plugins

# GET THE MAXIMUN CAPACITY VALUE FROM SNMP
max_level=`$nagios_plug_dir/check_snmp -H $HOST -C public -o mib-2.43.11.1.1.8.1.1`
RES=$?

# GET CURRENT SUPPLY LEVEL FROM SNMP
current_level=`$nagios_plug_dir/check_snmp -H $HOST -C public -o mib-2.43.11.1.1.9.1.1`
RES=$?

#BAIL OUT IF ANYTHING WENT WRONG
if [ $RES != 0 ]; then
        INK="Toner Unknown - SNMP problem. No data received from host.";
        echo $INK;
        STATUS=3;
        exit $STATUS;
fi

#EXTRACT VALUES FROM CHECK_SNMP COMMANDS
new_max_level=`echo $max_level|cut -d ' ' -f4`
new_current_level=`echo $current_level|cut -d ' ' -f4`
result=$(echo "scale=2; $new_current_level / $new_max_level;" | bc)

#ACTUAL VALUE OF TONER SUPPLY
percent=`echo "$result"*"100"/"1"|bc`

#CHECK WARNING AND CRITICAL LEVELS
        if [ $percent -le $CRIT ]; then
                echo "Toner Critical - "$INK $percent"%";
                STATUS=2
        elif [ $percent -le $WARN ]; then
                echo "Toner Warning - "$INK $percent"%";
                STATUS=1
        else
                echo "Toner OK - "$INK $percent"%"
        fi

exit $STATUS

