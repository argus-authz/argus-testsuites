#!/bin/bash

script_name=`basename $0`
failed="no"
policyfile=policyfile.txt

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

wget http://localhost:8151/status > /dev/null 2>&1
result=$?
if [ $result -ne 0 ]
then 
    echo "${script_name}: wget http://localhost:8151/status SHOULD work. Not OK."
    failed="yes"
fi

wget --certificate=/etc/grid-security/hostcert.pem \
     --private-key=/etc/grid-security/hostkey.pem \
     --ca-directory=/etc/grid-security/certificates \
     --no-check-certificate \
     https://${host}:8150/status  > /dev/null 2>&1
result=$?

if [ $result -eq 0 ]
then
    echo "${script_name}: wget https://${host}:8150/status SHOULD NOT work. Not OK."
    failed="yes"
fi

if [ $failed == "yes" ]; then
  echo "---${script_name}: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---${script_name}: TEST PASSED---"
  echo `date`
  exit 0
fi

