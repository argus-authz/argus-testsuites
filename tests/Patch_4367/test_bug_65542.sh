#!/bin/sh

script_name=`basename $0`
failed="no"

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

PEP_CTRL=argus-pepd
if [ -f /etc/rc.d/init.d/pepd ];then PEP_CTRL=pepd;fi
echo "PEP_CTRL set to: /etc/rc.d/init.d/pep"

PDP_CTRL=argus-pdp
if [ -f /etc/rc.d/init.d/pdp ];then PDP_CTRL=pdp;fi
echo "PDP_CTRL set to: /etc/rc.d/init.d/$PDP_CTRL"

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

# Make sure we do NOT have a PAP running at start

/etc/rc.d/init.d/$PAP_CTRL stop > /dev/null 2>&1;
sleep 3;
/etc/rc.d/init.d/$PAP_CTRL status > /dev/null 2>&1;
result=$?
if [ $? -ne 0 ]; then
  echo "$PAP_CTRL status should return non-zero. returned ${result}."
  failed="yes"
  exit 1
else
  echo "$PAP_CTRL status returned ${result}. OK."
fi

/etc/init.d/$PDP_CTRL stop > /dev/null 2>&1;
sleep 3;
/etc/init.d/$PDP_CTRL status > /dev/null 2>&1;
result=$?; 
if [ $? -ne 0 ]; then
  echo "pdp status should return non-zero. returned ${result}."
  failed="yes"
  exit 1
else
  echo "pdp status returned ${result}. OK."
fi

/etc/init.d/pepd stop > /dev/null 2>&1;
sleep 3;
/etc/init.d/pepd status > /dev/null 2>&1;
result=$?;
if [ $? -ne 0 ]; then
  echo "pepd status should return non-zero. returned ${result}."
  failed="yes"
  exit 1
else
  echo "pepd status returned ${result}. OK."
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

