#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

failed="no"
policyfile=policyfile.txt


echo `date`
###############################################################
echo "---Test-Remove-Policies---"
echo "1) testing removal with non existing id"

$PAP_HOME/bin/pap-admin rp dummy_id

if [ $? -ne 0 ]; then
  echo "OK"
else
  echo "Failed"
  failed="yes"
fi

###############################################################
echo "2) testing removal with resource id"

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
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
id=`$PAP_HOME/bin/pap-admin lp -srai | egrep -m 1 'id=' | awk '{print $1}' | sed 's/id=//'`
echo "ID=$id"
#Removing policy
$PAP_HOME/bin/pap-admin rp $id

if [ $? -eq 0 ]; then
  echo "OK" 
else
  echo "Failed"
  failed="yes"
fi

###############################################################
# Retrieve resource id
echo "3) testing removal with action id"

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
    action "submit-job" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }

    action "get-status" {
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

#Retrieve last action is
id=`$PAP_HOME/bin/pap-admin lp -srai | egrep 'id=' | tail -1 | awk '{print $1}' | sed 's/id=//'`
echo "ID=$id"
#Removing last action rule
$PAP_HOME/bin/pap-admin rp $id

if [ $? -eq 0 ]; then
  lines=`$PAP_HOME/bin/pap-admin lp -srai | egrep -c 'id='`
  if [ $lines -ne 2 ]; then
    echo "Failed"
    echo "Found !2 id elements"
  else
    echo "OK"
  fi
else
  echo "Failed"
  failed="yes"
fi

###############################################################
echo "4) testing removal with rule id"

#Remove all policies defined for the default pap
$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_HOME/bin/pap-admin rap"
  exit 1
fi

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
    action "get-status" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name 2" }
    }
}

EOF
$PAP_HOME/bin/pap-admin apf $policyfile
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $PAP_HOME/bin/pap-admin apf $policyfile"
  exit 1
fi

#Retrieve last rule
id=`$PAP_HOME/bin/pap-admin lp -sai | egrep 'id=' | tail -1 | awk '{print $1}' | sed 's/id=//'`
echo "ID=$id"
#Removing last action rule
$PAP_HOME/bin/pap-admin rp $id

if [ $? -eq 0 ]; then
  lines=`$PAP_HOME/bin/pap-admin lp -sai | egrep -c 'id='`
  if [ $lines -ne 3 ]; then
    echo "Failed"
    echo "Found !3 id elements"
  else
    echo "OK"
  fi
else
  echo "Failed"
  failed="yes"
fi

###############################################################
echo "5) testing removal with multiple rules"

#Remove all policies defined for the default pap
$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_HOME/bin/pap-admin rap"
  exit 1
fi

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
    action "get-status" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name 2" }
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999997/CN=user name 3" }
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name 2" }
    }
}

EOF
$PAP_HOME/bin/pap-admin apf $policyfile
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $PAP_HOME/bin/pap-admin apf $policyfile"
  exit 1
fi

#Retrieve the last 3 rules id
id=`$PAP_HOME/bin/pap-admin lp -sai | egrep 'id=' | tail -4 | head -3 | awk '{print $1}' | sed 's/id=//'`
echo "ID=$id"
#Removing the last 3 rules
$PAP_HOME/bin/pap-admin rp $id

if [ $? -eq 0 ]; then
  lines=`$PAP_HOME/bin/pap-admin lp -sai | egrep -c 'id='`
  if [ $lines -ne 3 ]; then
    echo "Failed"
    echo "Found !3 id elements"
  else
    echo "OK"
  fi
else
  echo "Failed"
  failed="yes"
fi

###############################################################
echo "6) testing removal with multiple rules and one wrong"

#Remove all policies defined for the default pap
$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_HOME/bin/pap-admin rap"
  exit 1
fi

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
    action "get-status" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name 2" }
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999997/CN=user name 3" }
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name 2" }
    }
}

EOF
$PAP_HOME/bin/pap-admin apf $policyfile
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $PAP_HOME/bin/pap-admin apf $policyfile"
  exit 1
fi

#Retrieve the last 3 rules id
id=`$PAP_HOME/bin/pap-admin lp -sai | egrep 'id=' | tail -4 | head -3 | awk '{print $1}' | sed 's/id=//'`
echo "ID=$id"
#Removing the last 3 rules
$PAP_HOME/bin/pap-admin rp $id another-non-existing-id

if [ $? -ne 0 ]; then
  lines=`$PAP_HOME/bin/pap-admin lp -sai | egrep -c 'id='`
  if [ $lines -ne 3 ]; then
    echo "Failed"
    echo "Found !3 id elements"
  else
    echo "OK"
  fi
else
  echo "Failed"
  failed="yes"
fi

###############################################################
echo "7) testing removal with empty repository"

$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $PAP_HOME/bin/pap-admin rap"
  exit 1
fi

$PAP_HOME/bin/pap-admin rp $id
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
  echo "---Test-Remove-Polices: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Remove-Polices: TEST PASSED---"
  echo `date`
  exit 0
fi

