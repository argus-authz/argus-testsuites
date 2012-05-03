#!/bin/sh

script_name=`basename $0`
passed="yes"

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

#########################################################



echo `date`
echo "---Test: argus-pap RPM upgrade overwrite pap-admin.properties---"
#########################################################

echo "1) See if the mentioned config file is properly declared in the rpm:"
rpm -qlc argus-pap | grep pap-admin.properties
if [ $? -ne 0 ]; then
	passed="no"
else
	echo "yes it is!"
fi



if [ $passed == "no" ]; then
echo "---Test: argus-pap RPM upgrade overwrite pap-admin.properties TEST FAILED---"
echo `date`
exit 1
else
echo "---Test: argus-pap RPM upgrade overwrite pap-admin.properties TEST PASSED---"
echo `date`
exit 0
fi
