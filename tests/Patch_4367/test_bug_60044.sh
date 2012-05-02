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
echo "Testing bug 60044."

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
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

resource "resource_2" {
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name" }
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
resource "resource_3" {
    action "execute" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999997/CN=user name" }
    }
}
EOF
$PAP_ADMIN apf $policyfile
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $PAP_ADMIN apf $policyfile"
  exit 1
fi

$PAP_ADMIN lp --resource "resource_2" | grep -q "999998"
if [ $? -ne 0 ]
then
    failed="yes"
else
    echo "$script_name: passed lp by resource."
fi

# probably should verify by action as well?

$PAP_ADMIN lp --action "execute" | grep -q "999997"
if [ $? -ne 0 ]
then
    failed="yes"
else
    echo "$script_name: passed lp by valid action."
fi

$PAP_ADMIN lp --action "spare" | grep -q "No policies has been found."
if [ $? -ne 0 ]
then
    failed="yes"
else
    echo "$script_name: passed lp by Invalid action."
fi

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

