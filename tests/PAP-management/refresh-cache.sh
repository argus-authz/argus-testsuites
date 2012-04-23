#!/bin/sh

failed="no"

if [ -z $T_PAP_HOME ]
then
    if [ -d /usr/share/argus/pap ]
    then
        T_PAP_HOME=/usr/share/argus/pap
    else
        if [ -d /opt/argus/pap ]
        then
            T_PAP_HOME=/opt/argus/pap
        else
            echo "T_PAP_HOME not set, not found at standard locations. Exiting."
            exit 2;
        fi
    fi
fi
T_PAP_CTRL=argus-pap
if [ -f /etc/rc.d/init.d/pap-standalone ]
then
    T_PAP_CTRL=pap-standalone
fi
echo "T_PAP_CTRL set to: /etc/rc.d/init.d/$T_PAP_CTRL"
/etc/rc.d/init.d/$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  /etc/rc.d/init.d/$T_PAP_CTRL start
  sleep 10
fi

/etc/rc.d/init.d/$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  exit 1
fi

echo `date`
echo "---Test-Refesh-Cache---"
###############################################################
echo "1) testing rc with non existing alias"
$T_PAP_HOME/bin/pap-admin rc Do-Not-Exist
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "2) testing rc with a local pap"
$T_PAP_HOME/bin/pap-admin rc default
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
if [ $failed == "yes" ]; then
  echo "---Test-Refesh-Cache: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Refesh-Cache: TEST PASSED---"
  echo `date`
  exit 0
fi

