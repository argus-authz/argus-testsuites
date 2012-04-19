#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

failed="no"
policyfile=policyfile.txt

echo `date`
echo "---Test-Remove-All-Policies---"
###############################################################
echo "1) testing remove all policies "

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}
resource "resource_2" {
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}
resource "resource_3" {
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}

EOF
$PAP_HOME/bin/pap-admin apf $policyfile
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $PAP_HOME/bin/pap-admin apf $policyfile"
  exit 1
fi

#remove all
$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $PAP_HOME/bin/pap-admin rap"
  exit 1
fi


#Retrieve resource id
lines=`$PAP_HOME/bin/pap-admin lp -sai | egrep -c 'id='`

if [ $lines -eq 0 ]; then
  echo "OK" 
else
  echo "Failed"
  failed="yes"
fi

###############################################################
#clean up
rm -f $policyfile

if [ $failed == "yes" ]; then
  echo "---Test-Remove-All-Polices: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Remove-All-Polices: TEST PASSED---"
  echo `date`
  exit 0
fi

