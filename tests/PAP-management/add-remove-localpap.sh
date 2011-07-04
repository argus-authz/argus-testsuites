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
echo "---Add/Remove-local-PAP---"
###############################################################
echo "1) testing apap with existing alias"
$PAP_HOME/bin/pap-admin apap default
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "2) testing apap with wrong endpoint"
$PAP_HOME/bin/pap-admin apap NewPAP --url "https://localhost:8555/pap/services/"
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "3) testing apap local"
$PAP_HOME/bin/pap-admin apap NewPAP 
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  $PAP_HOME/bin/pap-admin list-paps | grep -q 'NewPAP'
  if [ $? -ne 0 ]; then
    echo "Failed"
    failed="yes"
  else
    echo "OK"
  fi
fi

###############################################################
echo "3) test removing local pap"
$PAP_HOME/bin/pap-admin remove-pap NewPAP
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "4) test removing local default pap"
$PAP_HOME/bin/pap-admin rpap default
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "5) test removing non-existing pap"
$PAP_HOME/bin/pap-admin rpap Dummy
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
if [ $failed == "yes" ]; then
  echo "---Test-Add/Remove-local-PAP: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Add/Remove-local-PAP: TEST PASSED---"
  echo `date`
  exit 0
fi

