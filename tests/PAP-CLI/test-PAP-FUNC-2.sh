#!/bin/bash

#Assumptions: The PAP is running with a correct configuration file
#Note: Each single test has this assumption

echo `date`
echo "---Test-PAP-FUNC-2---"

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

conffile=$PAP_HOME/conf/pap_configuration.ini
bkpfile=$PAP_HOME/conf/pap_configuration.bkp
argusconffile=$PAP_HOME/conf/pap_authorization.ini
argusbkpfile=$PAP_HOME/conf/pap_authorization.bkp
failed="no"

PAP_CTRL=argus-pap

# gLite case
if [ -f /etc/rc.d/init.d/pap-standalone ]
then
    PAP_CTRL=pap-standalone
fi

echo "PAP_CTRL set to: /etc/rc.d/init.d/$PAP_CTRL"

/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP running'

if [ $? -ne 0 ]; then
  echo "PAP is not running"
  /etc/rc.d/init.d/$PAP_CTRL start; result=$?
  sleep 5;
  if [ $result -ne 0 ]
  then
      echo "PAP is not running: A start was attempted."
      echo "Failed"
      exit 1
  else
      echo "PAP started. Proceeding."
  fi
fi


#################################################################
echo "1) testing missing configuration file"

mv $conffile $bkpfile
/etc/rc.d/init.d/$PAP_CTRL restart >>/dev/null
sleep 10
/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  mv -f $bkpfile $conffile
  echo "FAILED"
else
  mv -f $bkpfile $conffile
  /etc/rc.d/init.d/$PAP_CTRL start >>/dev/null
  sleep 40
  echo "OK"
fi

#################################################################
echo "2) testing missing argus file"
mv -f $argusconffile  $argusbkpfile

/etc/rc.d/init.d/$PAP_CTRL restart >>/dev/null
sleep 10
/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  echo "FAILED"
  mv -f $argusbkpfile $argusconffile
else
  mv -f $argusbkpfile $argusconffile
  /etc/rc.d/init.d/$PAP_CTRL start >>/dev/null
  sleep 40
  echo "OK"
fi

#################################################################
#start/restart the server
/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP not running'
if [ $? -eq 0 ]; then
  /etc/rc.d/init.d/$PAP_CTRL start >>/dev/null
else
  /etc/rc.d/init.d/$PAP_CTRL restart >>/dev/null
fi
sleep 10

if [ $failed == "yes" ]; then
  echo "---Test-PAP-FUNC-2: TEST FAILED---"
  echo `date`
  exit 1
else
  echo "---Test-PAP-FUNC-2: TEST PASSED---"
  echo `date`
  exit 0
fi

