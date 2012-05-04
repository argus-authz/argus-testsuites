#!/bin/sh

script_name=`basename $0`
passed="yes"

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh


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
