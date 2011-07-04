#!/bin/sh

script_name=`basename $0`
failed="no"
host=`hostname`

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
/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  /etc/rc.d/init.d/$PAP_CTRL start
  sleep 10
fi
## To here for EGEE/EMI compatible tests

wget http://localhost:8151/status > /dev/null 2>&1
result=$?
if [ $result -ne 0 ]
then 
    echo "${script_name}: wget http://localhost:8151/status SHOULD work. Not OK."
    failed="yes"
fi

wget --certificate=/etc/grid-security/hostcert.pem \
     --private-key=/etc/grid-security/hostkey.pem \
     --ca-directory=/etc/grid-security/certificates \
     --no-check-certificate \
     https://${host}:8150/status  > /dev/null 2>&1
result=$?

if [ $result -eq 0 ]
then
    echo "${script_name}: wget https://${host}:8150/status SHOULD NOT work. Not OK."
    failed="yes"
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

