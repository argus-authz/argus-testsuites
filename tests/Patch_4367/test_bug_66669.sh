#!/bin/bash

script_name=`basename $0`
failed="no"
policyfile=policyfile.txt

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  exit 1
fi

#Remove all policies defined for the default pap
$PAP_ADMIN rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_ADMIN rap"
  exit 1
fi

echo `date`

###############################################################
echo "Running: ${script_name}"

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name/testslash" }
    }
}
EOF
$PAP_ADMIN apf $policyfile
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $PAP_ADMIN apf $policyfile"
  exit 1
fi

cat <<EOF > $policyfile
resource "resource_1" {
    action ".*" {
        rule permit { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/slashtest/CN=user/CN=999999/CN=user name" }
    }
}
EOF

$PAP_ADMIN apf $policyfile
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $PAP_ADMIN apf $policyfile"
  exit 1
fi

$PAP_ADMIN lp --resource "resource_1"

###############################################################
#clean up

clean_up=0
# clean_up=1

if [ $clean_up -eq 0 ]
then
rm -f $policyfile
#Remove all policies defined for the default pap
$PAP_ADMIN rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_ADMIN rap"
  exit 1
fi
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

