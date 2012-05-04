#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

failed="no"
policyfile=policyfile.txt

echo `date`
###############################################################
echo "---Test-Update-Policy-From-File---"
echo "1) testing upf with non existing file"

$T_PAP_HOME/bin/pap-admin upf resource_id dummy.txt

if [ $? -ne 0 ]; then
  echo "OK"
else
  echo "Failed"
  failed="yes"
fi

###############################################################
echo "2) testing upf with non existing resource id"

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}
EOF
$T_PAP_HOME/bin/pap-admin apf $policyfile
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $T_PAP_HOME/bin/pap-admin apf $policyfile"
  exit 1
fi


#Create new policy file
cat <<EOF > $policyfile
resource "resource_1" {
   action ".*" {
        rule permit { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}
EOF

$T_PAP_HOME/bin/pap-admin upf dummy-id-999 $policyfile
if [ $? -ne 0 ]; then
  echo "OK" 
else
  echo "Failed"
  failed="yes"
fi

###############################################################
# Retrieve resource id
echo "3) testing upf with correct resource id "

#Create new policy file
cat <<EOF > $policyfile
resource "resource_1" {
   action ".*" {
        rule permit { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}
EOF

id=`$T_PAP_HOME/bin/pap-admin lp -srai | egrep 'id=[^public]' | sed 's/id=//'`
sleep 5
echo "ID=$id"
$T_PAP_HOME/bin/pap-admin upf $id $policyfile
if [ $? -eq 0 ]; then
  echo "OK" 
else
  echo "Failed"
  failed="yes"
fi

###############################################################
# Retrieve resource id

echo "4) testing upf with changing only an action "

#Create new policy file
cat <<EOF > $policyfile
action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
}
EOF

#Retrieve action id and update policy
id=`$T_PAP_HOME/bin/pap-admin lp -srai | egrep 'id=public' | awk '{print $1}' | sed 's/id=//'`
echo "ID=$id"
$T_PAP_HOME/bin/pap-admin upf $id $policyfile
if [ $? -eq 0 ]; then
  echo "OK" 
else
  echo "Failed"
  echo "Command run was: $T_PAP_HOME/bin/pap-admin upf $id $policyfile"
  failed="yes"
fi

###############################################################
#clean up
rm -f $policyfile

if [ $failed == "yes" ]; then
  echo "---Test-Update-Policy-From-File: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Update-Policy-From-File: TEST PASSED---"
  echo `date`
  exit 0
fi

