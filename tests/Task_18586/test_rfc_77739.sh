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
echo "---Test: GSI PEP plugin thread-safe---"
#########################################################

echo "1) Testing if gsi dependency is set to the thread-save library"
yum deplist argus-gsi-pep-callout | grep 'dependency: libargus-pep.so.2' >>/dev/null
if [ $? -eq 0 ]; then
echo "OK" 
else
echo "Failed"
passed="no"
fi
echo "-------------------------------"

echo "2) Testing if gsi provides is set to the thread-save library"
yum deplist argus-gsi-pep-callout | grep 'provider: argus-pep-api-c.x86_64 2' >>/dev/null
if [ $? -eq 0 ]; then
echo "OK" 
else
echo "Failed"
passed="no"
fi
echo "-------------------------------"



if [ $passed == "no" ]; then
echo "---Test: GSI PEP plugin thread-safe: TEST FAILED---"
echo `date`
exit 1
else
echo "---Test: GSI PEP plugin thread-safe: TEST PASSED---"
echo `date`
exit 0
fi
