#!/bin/sh

script_name=`basename $0`
failed="no"

## This is the needed bit to make EGEE/EMI compatible tests
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

T_PEP_CTRL=argus-pepd
if [ -f /etc/rc.d/init.d/pepd ];then T_PEP_CTRL=pepd;fi
echo "T_PEP_CTRL set to: /etc/rc.d/init.d/pep"

T_PDP_CTRL=argus-pdp
if [ -f /etc/rc.d/init.d/pdp ];then T_PDP_CTRL=pdp;fi
echo "T_PDP_CTRL set to: /etc/rc.d/init.d/$T_PDP_CTRL"

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
## To here for EGEE/EMI compatible tests

# Make sure we do NOT have a PAP running at start

/etc/rc.d/init.d/$T_PAP_CTRL stop > /dev/null 2>&1;
sleep 3;
/etc/rc.d/init.d/$T_PAP_CTRL status > /dev/null 2>&1;
result=$?
if [ $? -ne 0 ]; then
  echo "$T_PAP_CTRL status should return non-zero. returned ${result}."
  failed="yes"
  exit 1
else
  echo "$T_PAP_CTRL status returned ${result}. OK."
fi

/etc/init.d/$T_PDP_CTRL stop > /dev/null 2>&1;
sleep 3;
/etc/init.d/$T_PDP_CTRL status > /dev/null 2>&1;
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

