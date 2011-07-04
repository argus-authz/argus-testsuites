#!/bin/sh

## This is the needed bit to make EGEE/EMI compatible tests
if [ -z $PAP_HOME ]
then
    if [ -d /usr/share/argus/pap ]
    then
        PAP_HOME=/usr/share/argus/pap
    else
        if [ -d /opt/argus/pap ]
        then
            PAP_HOME=/opt/argus/pap
        else
            echo "PAP_HOME not set, not found at standard locations. Exiting."
            exit 2;
        fi
    fi
fi
PAP_CTRL=argus-pap
if [ -f /etc/rc.d/init.d/pap-standalone ]
then
    PAP_CTRL=pap-standalone
fi
echo "PAP_CTRL set to: /etc/rc.d/init.d/$PAP_CTRL"
/etc/rc.d/init.d/argus-pap status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  /etc/rc.d/init.d/$PAP_CTRL start
  sleep 10
fi
## To here for EGEE/EMI compatible tests

failed="no"
policyfile=policyfile.txt

/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  exit 1
fi

#Remove all policies defined for the default pap
$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_HOME/bin/pap-admin rap"
  exit 1
fi

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
#Remove all policies defined for the default pap
$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_HOME/bin/pap-admin rap"
  exit 1
fi


if [ $failed == "yes" ]; then
  echo "---Test-List-Polices: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-List-Polices: TEST PASSED---"
  echo `date`
  exit 0
fi

