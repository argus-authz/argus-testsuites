#!/bin/sh

script_name=`basename $0`
passed="yes"

#########################################################
# Test if the Services are present on the system and setting some variables
# This is done for every test, even if the variables are not needed
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
echo "---Test: PAP changes bind IP using localhost---"
#########################################################

echo "1) Testing if port 8150 is listen on hostname"
netstat -l | grep `hostname`:8150 | grep LISTEN
if [ $? -eq 0 ]; then
echo "OK" 
else
echo "Failed"
passed="no"
fi
echo "-------------------------------"

echo "2) Testing if port 8151 is listen on localhost"
netstat -l | grep localhost | grep 8151 | grep LISTEN
if [ $? -eq 0 ]; then
echo "OK" 
else
echo "Failed"
passed="no"
fi
echo "-------------------------------"



if [ $passed == "no" ]; then
echo "---Test: PAP changes bind IP using localhost: TEST FAILED---"
echo `date`
exit 1
else
echo "---Test: PAP changes bind IP using localhost: TEST PASSED---"
echo `date`
exit 0
fi
