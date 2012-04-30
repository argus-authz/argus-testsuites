#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  exit 1
fi

TMP_BIN=/tmp/bin

if [ ! -d ${TMP_BIN} ]
then
    mkdir -p /tmp/bin
fi
if [ -f ${TMP_BIN}/pap-admin ]
then
    rm ${TMP_BIN}/pap-admin
fi

export PATH=$PATH:${TMP_BIN}

ln -s /opt/argus/pap/bin/pap-admin ${TMP_BIN}/pap-admin

#Remove all policies defined for the default pap
pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: pap-admin rap"
  exit 1
fi

echo `date`

###############################################################

#Store initial policy
cat <<EOF > $policyfile
resource "resource_1" {
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name" }
    }
}
EOF

pap-admin apf $policyfile

cat <<EOF > $policyfile
resource "resource_2" {
    action ".*" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999998/CN=user name" }
    }
}
EOF

pap-admin apf $policyfile

cat <<EOF > $policyfile
resource "resource_3" {
    action "execute" {
        rule deny { subject="/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999997/CN=user name" }
    }
}
EOF

pap-admin apf $policyfile

pap-admin lp > /dev/null 2>&1
result=$?
if [ $result -ne 0 ]
then
    failed="yes"
    echo "${script_name}: pap-admin lp failed. Not OK."
fi

###############################################################
#clean up

clean_up=0
# clean_up=1

if [ $clean_up -eq 0 ]
then
rm -f $policyfile
#Remove all policies defined for the default pap
pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: pap-admin rap"
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

