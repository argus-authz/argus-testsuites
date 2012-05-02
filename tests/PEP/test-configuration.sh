#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

echo `date`
echo "---Test-PEP-Configuration---"

conffile=$T_PEP_HOME/conf/pepd.ini
bkpconffile=$T_PEP_HOME/conf/pepd.bkp
bkpconffile2=$T_PEP_HOME/conf/pepd.bkp2
failed="no"

#################################################################
echo "1) testing pep status"

$T_PEP_CTRL status | grep -q "argus-pepd is running..."
if [ $? -eq 0 ]; then
    echo "OK"
else
    failed="yes"
    echo "Failed"
fi

#################################################################
echo "2) testing pep with SSL"
$T_PEP_CTRL stop
mv $conffile $bkpconffile
#Insert SSL option
sed '/SERVICE/a\enableSSL = true' $bkpconffile > $conffile

$T_PEP_CTRL start
sleep 5
if [ $? -eq 0 ]; then
    echo "OK"
    else
    failed="yes"
    echo "Failed"
fi

#################################################################

echo "3) testing pep with no config file"
$T_PEP_CTRL stop
mv $conffile $bkpconffile2
$T_PEP_CTRL start
sleep 5
$T_PEP_CTRL status | grep -q "argus-pepd is running..."
if [ $? -ne 0 ] ; then
    echo "OK"
else
    failed="yes"
    echo "Failed"
fi

#################################################################

mv $bkpconffile $conffile
rm -f $bkpconffile2
$T_PEP_CTRL restart >>/dev/null
sleep 5

if [ $failed == "yes" ]; then
    echo "---Test-PEP-Configuration: TEST FAILED---"
    echo `date`
    exit 1
else
    echo "---Test-PEP-Configuration: TEST PASSED---"
    echo `date`
    exit 0
fi

