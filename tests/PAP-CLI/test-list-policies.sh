#!/bin/sh

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh
policyfile=policyfile.txt

# Start test
failed="no"

echo `date`
echo "---Test-List-Policies---"
###############################################################
echo "1) testing list policies on an empty repository"

$PAP_HOME/bin/pap-admin lp 

if [ $? -eq 0 ]; then
  echo "OK" 
else
  echo "Failed"
  failed="yes"
fi

###############################################################
echo "2) testing list policies"

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
    obligation "http://glite.org/xacml/obligation/local-environment-map" {}
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}
resource "resource_2" {
    obligation "http://glite.org/xacml/obligation/local-environment-map" {}
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}
resource "resource_3" {
    obligation "http://glite.org/xacml/obligation/local-environment-map" {}
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

#Retrieve resource id
lines=`$PAP_HOME/bin/pap-admin lp -sai | egrep -c 'id='`

if [ $lines -eq 9 ]; then
  echo "OK" 
else
  echo "Failed"
  echo "expecting 9 ids, found $lines"
  failed="yes"
fi

###############################################################
echo "2) testing list policies with wrong pap-alias"

#Retrieve resource id
$PAP_HOME/bin/pap-admin lp -sai --pap "dummy_pap"

if [ $? -ne 0 ]; then
  echo "OK" 
else
  echo "Failed"
  failed="yes"
fi

###############################################################
#clean up
rm -f $policyfile

if [ $failed == "yes" ]; then
  echo "---Test-List-Polices: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-List-Polices: TEST PASSED---"
  echo `date`
  exit 0
fi

