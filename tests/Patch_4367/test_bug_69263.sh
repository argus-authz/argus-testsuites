#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

script_name=`basename $0`
failed="no"

echo "Running: ${script_name}"
echo `date`

$T_PEP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
    echo "${script_name}: PEPd is not running. Good."
else
    echo "${script_name}: Stopping PEPd."
    $T_PEP_CTRL stop > /dev/null
    sleep 5
fi

# Change the pips section to comment out...

grep pips $T_PEP_CONF/$T_PEP_INI
echo "changed to:"
sed -i 's/pips =/# pips =/g' $T_PEP_CONF/$T_PEP_INI
grep pips $T_PEP_CONF/$T_PEP_INI
# Now try to start pepd.

echo "${script_name}: Starting PEPd."
$T_PEP_CTRL start > /dev/null
result=$?
sleep 5
# echo $result
if [ $result -eq 0 ]
then
    echo "${script_name}: Stopping PEPd."
    $T_PEP_CTRL stop > /dev/null
    sleep 5
else
    echo "${script_name}: PEPd failed to start."
    failed="yes"
fi

# Now restore to original

rm -f $T_PEP_CONF/$T_PEP_INI
cp -f $SCRIPTBACKUPLOCATION/$T_PEP_INI $T_PEP_CONF/$T_PEP_INI

# Now try to start pepd.

echo "${script_name}: Starting PEPd."
$T_PEP_CTRL start > /dev/null
result=$?
sleep 5
# echo $result
if [ $result -ne 0 ]
    echo "${script_name}: PEPd failed to start."
    failed="yes"
fi


###############################################################


if [ $failed == "yes" ]; then
  echo "---${script_name}: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---${script_name}: TEST PASSED---"
  echo `date`
  exit 0
fi

