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
/etc/rc.d/init.d/argus-pap status | grep -q 'PAP running'
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
echo "---Test-Enable/Disable-PAP---"
###############################################################
echo "1) testing dpap with non existing pap"
$T_PAP_HOME/bin/pap-admin dpap mypap
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "2) testing dpap with already disabled pap"

#Add pap
$T_PAP_HOME/bin/pap-admin apap mypap 
if [ $? -ne 0 ]; then
  echo "Failed adding a pap"
  exit 1
fi

$T_PAP_HOME/bin/pap-admin dpap mypap
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "3) testing epap with wrong alias"
$T_PAP_HOME/bin/pap-admin epap Dummy
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "4) testing epap with good alias"
$T_PAP_HOME/bin/pap-admin epap mypap
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  $T_PAP_HOME/bin/pap-admin list-paps | grep mypap | grep -q enabled
  if [ $? -eq 0 ]; then
    echo "OK"
  else
    echo "Failed"
    failed="yes"
  fi
fi

###############################################################
echo "4) testing dpap with good alias"
$T_PAP_HOME/bin/pap-admin dpap mypap
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  $T_PAP_HOME/bin/pap-admin list-paps | grep mypap | grep -q disabled
  if [ $? -eq 0 ]; then
    echo "OK"
  else
    echo "Failed"
    failed="yes"
  fi
fi

###############################################################
echo "5) testing dpap default pap"
$T_PAP_HOME/bin/pap-admin dpap default
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  $T_PAP_HOME/bin/pap-admin list-paps | grep default | grep -q disabled
  if [ $? -eq 0 ]; then
    echo "OK"
  else
    echo "Failed"
    failed="yes"
  fi
fi

###############################################################
echo "6) testing epap default pap"
$T_PAP_HOME/bin/pap-admin epap default
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else 
  $T_PAP_HOME/bin/pap-admin list-paps | grep default | grep -q enabled
  if [ $? -eq 0 ]; then
    echo "OK"
  else
    echo "Failed"
    failed="yes"
  fi
fi


###############################################################
#Remove pap
$T_PAP_HOME/bin/pap-admin rpap mypap
if [ $? -ne 0 ]; then
  echo "Failed removed pap"
fi


###############################################################
if [ $failed == "yes" ]; then
  echo "---Test-Enable/Disable-PAP: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Enable/Disable-PAP: TEST PASSED---"
  echo `date`
  exit 0
fi

