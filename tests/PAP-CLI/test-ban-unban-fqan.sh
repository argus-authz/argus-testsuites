#!/bin/sh

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test
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



