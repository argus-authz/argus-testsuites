#!/bin/sh

script_name=`basename $0`
passed="yes"

#########################################################
# Test if the Services are present on the system and setting some variables
if [ -z $PAP_HOME ]; then
    if [ -d /usr/share/argus/pap ]
    then
        PAP_HOME=/usr/share/argus/pap
    else
        echo "PAP_HOME not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

PAP_CTRL=argus-pap
if [ -f /etc/rc.d/init.d/pap-standalone ]; then
    PAP_CTRL=pap-standalone
fi


if [ -z $PDP_HOME ]; then
    if [ -d /usr/share/argus/pdp ]; then
        PAP_HOME=/usr/share/argus/pdp
    else
        echo "PDP_HOME not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

PDP_CTRL=argus-pdp
if [ -f /etc/rc.d/init.d/pdp ]; then
    PDP_CTRL=pdp;
fi


if [ -z $PEP_HOME ]; then
    if [ -d /usr/share/argus/pepd ]; then
        PEP_HOME=/usr/share/argus/pepd
    else
        echo "PEP_HOME not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

PEP_CTRL=argus-pepd
if [ -f /etc/rc.d/init.d/pepd ]; then
    PEP_CTRL=pepd;
fi
#########################################################
#########################################################



echo `date`
echo "---Test: Directory Structure---"
#########################################################

echo "1) testing if the proposed file-structure for PAP is given"
if ([ -d /etc/argus/pap ] && [ -f /etc/rc.d/init.d/argus-pap ] && [ -d /usr/share/argus/pap ] && [ -f /usr/bin/pap-admin ] && [ -f /usr/bin/pepcli ] && [ -f /usr/sbin/papctl ]); then
  echo "OK"
else
  echo "FAILED"
  passed="no"
fi
echo "-------------------------------"

echo "2) testing if the proposed file-structure for PEP is given"
if ([ -d /etc/argus/pepd ] && [ -f /etc/rc.d/init.d/argus-pepd ] && [ -d /usr/share/argus/pepd ] && [ -f /usr/sbin/pepdctl ]); then
echo "OK"
else
echo "FAILED"
  passed="no"
fi
echo "-------------------------------"

echo "3) testing if the proposed file-structure for PDP is given"
if ([ -d /etc/argus/pdp ] && [ -f /etc/rc.d/init.d/argus-pdp ] && [ -d /usr/share/argus/pdp ] && [ -f /usr/sbin/pdpctl ]); then
echo "OK"
else
echo "FAILED"
  passed="no"
fi
echo "-------------------------------"



if [ $passed == "no" ]; then
  echo "---Test: Directory Structure: TEST FAILED---"
  echo `date`
  exit 1
else
  echo "---Test: Directory Structure: TEST PASSED---"
  echo `date`
  exit 0
fi
