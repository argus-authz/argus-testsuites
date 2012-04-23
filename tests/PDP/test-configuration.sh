#!/bin/bash

#Assumtpions: The PDP is running with a correct configuration file
#Note: Each single test has this assumption


#Set the Home directory
if [ -z $T_PDP_HOME ]
then
    if [ -d /usr/share/argus/pdp ]
    then
        T_PAP_HOME=/usr/share/argus/pdp
    else
        echo "T_PDP_HOME not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

#Set the Process name
T_PDP_CTRL=argus-pdp
echo "T_PDP_CTRL set to: $T_PDP_CTRL"

#Set the Status info
PDP_INFO="Argus PDP"
echo "$PDP_INFO"

echo `date`
echo "---Test-PDP-Configuration---"

conffile=$T_PDP_HOME/conf/pdp.ini
failed="no"

#################################################################
echo "1) testing pdp status"

/etc/rc.d/init.d/$T_PDP_CTRL status | grep -q "Service: $PDP_INFO"
if [ $? -eq 0 ]; then
  echo "OK"
else
  failed="yes"
  echo "Failed"
fi

if [ $failed == "yes" ]; then
  echo "---Test-PDP-Configuration: TEST FAILED---"
  echo `date`
  exit 1
else
  echo "---Test-PDP-Configuration: TEST PASSED---"
  echo `date`
  exit 0
fi

