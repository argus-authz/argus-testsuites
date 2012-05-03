#!/bin/sh

script_name=`basename $0`
passed="yes"

#########################################################
# Test if the Services are present on the system and setting some variables
# This is done for every test, even if the variables are not needed
if [ -z $T_PAP_HOME ]; then
if [ -d /usr/share/argus/pap ]
then
T_PAP_HOME=/usr/share/argus/pap
else
echo "T_PAP_HOME not set, not found at standard locations. Exiting."
exit 2;
fi
fi

T_PAP_CTRL=argus-pap
if [ -f /etc/rc.d/init.d/pap-standalone ]; then
T_PAP_CTRL=pap-standalone
fi


if [ -z $T_PDP_HOME ]; then
if [ -d /usr/share/argus/pdp ]; then
T_PAP_HOME=/usr/share/argus/pdp
else
echo "T_PDP_HOME not set, not found at standard locations. Exiting."
exit 2;
fi
fi

T_PDP_CTRL=argus-pdp
if [ -f /etc/rc.d/init.d/pdp ]; then
T_PDP_CTRL=pdp;
fi


if [ -z $T_PEP_HOME ]; then
if [ -d /usr/share/argus/pepd ]; then
T_PEP_HOME=/usr/share/argus/pepd
else
echo "T_PEP_HOME not set, not found at standard locations. Exiting."
exit 2;
fi
fi

T_PEP_CTRL=argus-pepd
if [ -f /etc/rc.d/init.d/pepd ]; then
T_PEP_CTRL=pepd;
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


echo "3) Test if the PEPd is started with the memory option '-Xmx256':"
ps aux | grep pepd | grep -q Xmx256
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
