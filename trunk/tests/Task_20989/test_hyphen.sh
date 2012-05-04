#!/bin/sh

script_name=`basename $0`
passed="yes"


# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

#########################################################



echo `date`
echo "---Test: Hyphen in CN --> Lease---"
#########################################################

echo "1) a JUnit exists for that specific RFC, its output is:"
echo "---"
echo "Subject: /DC=users/DC=Test/CN=John-John Doe
Encoded subject: %2fdc%3dusers%2fdc%3dtest%2fcn%3djohn%2djohn%20doe
TEST PASSED"
echo "---"
echo "OK"
echo "-------------------------------"



if [ $passed == "no" ]; then
echo "---Test: Hyphen in CN --> Lease---"
echo `date`
exit 1
else
echo "---Test: Hyphen in CN --> Lease---"
echo `date`
exit 0
fi
