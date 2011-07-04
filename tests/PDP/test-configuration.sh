#!/bin/bash

#Assumtpions: The PDP is running with a correct configuration file
#Note: Each single test has this assumption


#Set the Home directory according the installation type (EMI or Glite)
if [ -z $PDP_HOME ]
then
    if [ -d /usr/share/argus/pdp ]
    then
        PAP_HOME=/usr/share/argus/pdp
    else
        if [ -d /opt/argus/pdp ]
        then
            PAP_HOME=/opt/argus/pdp
        else
            echo "PDP_HOME not set, not found at standard locations. Exiting."
            exit 2;
        fi
    fi
fi

#Set the Process name according the installation type (EMI or Glite)
PDP_CTRL=argus-pdp
if [ -f /etc/rc.d/init.d/pdp ]
then
    PDP_CTRL=pdp;
fi
echo "PDP_CTRL set to: $PDP_CTRL"

#Set the Status info according the installation type (EMI or Glite)
PDP_INFO=Argus
if [ "$PDP_CTRL" = "pdp" ]
then
    PDP_INFO=pdp;
fi
echo "$PDP_INFO"

echo `date`
echo "---Test-PDP-Configuration---"

conffile=$PDP_HOME/conf/pdp.ini
failed="no"

#################################################################
echo "1) testing pdp status"

/etc/rc.d/init.d/$PDP_CTRL status | grep -q "service: $PDP_INFO"
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

