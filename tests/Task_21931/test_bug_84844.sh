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
echo "---Test: implement memory limit---"
#########################################################

echo "1) Test if the PAP is started with the memory option '-Xmx256':"
ps aux | grep pap | grep -q Xmx256
if [ $? -ne 0 ]; then
        passed="no"
else
        echo "yes it is!"
fi
echo "-------------------------------"


echo "2) Test if the PDP is started with the memory option '-Xmx256':"
ps aux | grep pdp | grep -q Xmx256
if [ $? -ne 0 ]; then
        passed="no"
else 
        echo "yes it is!"
fi
echo "-------------------------------"


echo "3) Test if the PEPd is started with the memory option '-Xmx128':"
ps aux | grep pepd | grep -q Xmx128
if [ $? -ne 0 ]; then
        passed="no"
else 
        echo "yes it is!"
fi
echo "-------------------------------"

if [ $passed == "no" ]; then
echo "---Test: implement memory limit: TEST FAILED---"
echo `date`
exit 1
else
echo "---Test: implement memory limit: TEST PASSED---"
echo `date`
exit 0
fi
