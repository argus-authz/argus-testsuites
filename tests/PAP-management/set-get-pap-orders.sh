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
echo "---Test-Set/Get-paps-order---"
###############################################################
echo "1) testing gpo with no order"
$PAP_HOME/bin/pap-admin gpo
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "2) testing spo with 3 paps"

#Add 3 local paps
$PAP_HOME/bin/pap-admin apap local-pap1
$PAP_HOME/bin/pap-admin apap local-pap2
$PAP_HOME/bin/pap-admin apap local-pap3
if [ $? -ne 0 ]; then
  echo "Error addings paps"
  exit 1
fi


$PAP_HOME/bin/pap-admin spo local-pap1 local-pap2 local-pap3 default
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "2) Inverting the order"

$PAP_HOME/bin/pap-admin spo default local-pap3 local-pap2 local-pap1
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "3) using a non existing alias"

$PAP_HOME/bin/pap-admin spo default local-pp3 local-pp2 local-pp1 
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi


###############################################################
#Removing paps
$PAP_HOME/bin/pap-admin rpap local-pap1
$PAP_HOME/bin/pap-admin rpap local-pap2
$PAP_HOME/bin/pap-admin rpap local-pap3
if [ $? -ne 0 ]; then
  echo "Error removing paps"
fi



###############################################################
if [ $failed == "yes" ]; then
  echo "---Test-Set/Get-paps-order: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Set/Get-paps-order: TEST PASSED---"
  echo `date`
  exit 0
fi

