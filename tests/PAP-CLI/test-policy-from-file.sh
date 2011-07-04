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

policyfile=policyfile.txt
failed="no"

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

rm -f $policyfile

#Remove all policies defined for the default pap
$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_HOME/bin/pap-admin rap"
  exit 1
fi

if [ $failed == "yes" ]; then
  echo "---Test-APF: TEST FAILED---"
  echo `date`
  exit 1
else
  echo "---Test-APF: TEST PASSED---"
  echo `date`
  exit 0
fi

