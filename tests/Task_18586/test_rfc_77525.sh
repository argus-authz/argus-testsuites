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
echo "---Test: thread-safe PEP client library---"
#########################################################

echo "1) Testing if pepcli is using the thread-save library"
pepcli -V | grep argus-pep-api-c/2 >>/dev/null
if [ $? -eq 0 ]; then
    echo "OK" 
else
    echo "Failed"
    passed="no"
fi
echo "-------------------------------"

echo "2) Testing if the right rpm is installed"
rpm -q argus-pep-api-c >>/dev/null
if [ $? -eq 0 ]; then
    echo "OK" 
else
    echo "Failed"
    passed="no"
fi
echo "-------------------------------"



if [ $passed == "no" ]; then
    echo "---Test: thread-safe PEP client library: TEST FAILED---"
    echo `date`
    exit 1
else
    echo "---Test: thread-safe PEP client library: TEST PASSED---"
    echo `date`
    exit 0
fi
