#!/bin/bash

script_name=`basename $0`
passed="yes"

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

echo `date`
echo "---Test: files/dirs permission in RPM---"
#########################################################

echo "1) Nothing to test:"
echo "Nothing to test"
echo "OK"
echo "-------------------------------"



if [ $passed == "no" ]; then
echo "---Test: files/dirs permission in RPM: TEST FAILED---"
echo `date`
exit 1
else
echo "---Test: files/dirs permission in RPM: TEST PASSED---"
echo `date`
exit 0
fi

