#!/bin/sh

failed="no"

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

/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  exit 1
fi

echo `date`
echo "---Test-Update-PAP---"
###############################################################
echo "1) testing upap with non existing alias"
$PAP_HOME/bin/pap-admin upap Dummy
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
if [ $failed == "yes" ]; then
  echo "---Test-Update-PAP: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Update-PAP: TEST PASSED---"
  echo `date`
  exit 0
fi

