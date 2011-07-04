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
echo "---Test-Set/Get-Poll-Interval---"
###############################################################
echo "1) Setting polling time"
$PAP_HOME/bin/pap-admin spi 100
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "2) Retrieving polling time"
time=`$PAP_HOME/bin/pap-admin gpi 100 | sed 's/Polling interval in seconds: //g'`
if [ $time -ne 100 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
if [ $failed == "yes" ]; then
  echo "---Test-Set/Get-Poll-Interval: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Set/Get-Poll-Interval: TEST PASSED---"
  echo `date`
  exit 0
fi

