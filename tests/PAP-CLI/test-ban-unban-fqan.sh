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

echo `date`
echo "---Test-BAN/UNBAN-FQAN---"
echo "1) testing fqan ban"

$PAP_HOME/bin/pap-admin ban fqan "/badvo"

if [ $? -eq 0 ]; then
  echo "OK"
  echo "2) testing fqan unban"
  $PAP_HOME/bin/pap-admin un-ban fqan "/badvo"
  if [ $? -eq 0 ]; then
    echo "OK"
    echo "3) testing unbanning non existing fqan"
    $PAP_HOME/bin/pap-admin un-ban fqan "/badvo"
    if [ $? -ne 0 ]; then
      echo "OK"
      echo "---Test-BAN/UNBAND-FQAN: TEST PASSED---"
      echo `date`
      exit 0
    else
      echo "FAILED"
      echo "---Test-BAN/UNBAND-FQAN: TEST FAILED---"
      echo `date`
      exit 1
    fi
  else
    echo "FAILED"
    echo "---Test-BAN/UNBAND-FQAN: TEST FAILED---"
    echo `date`
    exit 1
  fi
else
  echo "FAILED"
  echo "---Test-BAN/UNBAND-FQAN: TEST FAILED---"
  echo `date`
  exit 1
fi



