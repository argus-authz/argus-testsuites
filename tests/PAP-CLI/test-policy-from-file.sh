#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test
policyfile=policyfile.txt
failed="no"

echo `date`
echo "---Test-APF---"
#########################################################
echo "1) testing add policy from file"
cat <<EOF > $policyfile
resource ".*" {

    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}
resource ".*" {

    action ".*" {
        rule deny { fqan="/badvo" }
    }
}
EOF

$PAP_HOME/bin/pap-admin apf $policyfile
if [ $? -eq 0 ]; then
  echo "OK"
else
  echo "FAILED"
  failed="yes"
fi

$PAP_HOME/bin/pap-admin un-ban subject "/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name"
$PAP_HOME/bin/pap-admin un-ban fqan "/badvo"

#########################################################
echo "2) testing add policy from file with error"
cat <<EOF > $policyfile
resource ".*" {

    action ".*" {
        rule deni { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}
EOF

$PAP_HOME/bin/pap-admin apf $policyfile
if [ $? -ne 0 ]; then
  echo "OK"
else
  echo "FAILED"
  failed="yes"
fi

# clean up
rm -f $policyfile


if [ $failed == "yes" ]; then
  echo "---Test-APF: TEST FAILED---"
  echo `date`
  exit 1
else
  echo "---Test-APF: TEST PASSED---"
  echo `date`
  exit 0
fi

