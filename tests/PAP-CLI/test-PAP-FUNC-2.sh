#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

#################################################################
echo "1) testing missing configuration file"

rm -f $PAP_CONF/$PAP_CONF_INI
$PAP_CTRL restart >>/dev/null
sleep 10
$PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
  echo "FAILED"
else
  cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
  $PAP_CTRL start >>/dev/null
  sleep 40
  echo "OK"
fi

#################################################################
echo "2) testing missing argus file"
rm -f $PAP_CONF/$PAP_AUTH_INI

$PAP_CTRL restart >>/dev/null
sleep 10
$PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  echo "FAILED"
  cp -f $SCRIPTBACKUPLOCATION/$PAP_AUTH_INI $PAP_CONF/$PAP_AUTH_INI
else
  cp -f $SCRIPTBACKUPLOCATION/$PAP_AUTH_INI $PAP_CONF/$PAP_AUTH_INI
  $PAP_CTRL start >>/dev/null
  sleep 40
  echo "OK"
fi

#################################################################
#start/restart the server
$PAP_CTRL status | grep -q 'PAP not running'
if [ $? -eq 0 ]; then
  $PAP_CTRL start >>/dev/null
else
  $PAP_CTRL restart >>/dev/null
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

