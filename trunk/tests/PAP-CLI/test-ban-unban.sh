#!/bin/sh

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test
echo `date`
echo "---Test-BAN/UNBAN---"
echo "1) testing user ban"

${T_PAP_HOME}/bin/pap-admin ban subject "/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name"

if [ $? -eq 0 ]; then
  echo "OK"
  echo "2) testing user unban"
  ${T_PAP_HOME}/bin/pap-admin un-ban subject "/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name"
  if [ $? -eq 0 ]; then
    echo "OK"
    echo "3) testing unbanning non existing subject"
    ${T_PAP_HOME}/bin/pap-admin un-ban subject "/DC=ch/DC=cern/OU=Organic Units/OU=Users/CN=user/CN=999999/CN=user name"
    if [ $? -ne 0 ]; then
      echo "OK"
      echo "---Test-BAN/UNBAND: TEST PASSED---"
      echo `date`
      exit 0
    else
      echo "FAILED"
      echo "---Test-BAN/UNBAND: TEST FAILED---"
      echo `date`
      exit 1
    fi
  else
    echo "FAILED"
    echo "---Test-BAN/UNBAND: TEST FAILED---"
    echo `date`
    exit 1
  fi
else
  echo "FAILED"
  echo "---Test-BAN/UNBAND: TEST FAILED---"
  echo `date`
  exit 1
fi



