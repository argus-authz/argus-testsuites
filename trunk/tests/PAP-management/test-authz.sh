#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

failed="no"

#################################################################
echo "1) testing lp with no authorization"

cat <<EOF > $T_PAP_CONF/$T_PAP_AUTH_INI
# Configuration file created by YAIM
[dn]
ANYONE : CONFIGURATION_READ
[fqan]
EOF

$T_PAP_CTRL restart >>/dev/null
sleep 5
$T_PAP_HOME/bin/pap-admin lp >>/dev/null
if [ $? -eq 0 ]; then
  failed="yes"
  echo "FAILED"
else
  echo "OK"
fi

#################################################################
#start/restart the server
rm -f $T_PAP_CONF/$T_PAP_AUTH_INI
mv -f $SCRIPTBACKUPLOCATION/$T_PAP_AUTH_INI $T_PAP_CONF/$T_PAP_AUTH_INI
$T_PAP_CTRL status | grep -q 'PAP not running'
if [ $? -eq 0 ]; then
    $T_PAP_CTRL start >>/dev/null
else
    $T_PAP_CTRL restart >>/dev/null
fi
sleep 10

#################################################################
echo "2) testing lp with anyone full power"

cat <<EOF > $T_PAP_CONF/$T_PAP_AUTH_INI
# Configuration file created by YAIM
[dn]
ANYONE : ALL
[fqan]
EOF

$T_PAP_CTRL restart >>/dev/null
sleep 10
$T_PAP_HOME/bin/pap-admin lp >>/dev/null
if [ $? -ne 0 ]; then
  failed="yes"
  echo "FAILED"
else
  echo "OK"
fi

#################################################################

if [ $failed == "yes" ]; then
  echo "---Test-argus: TEST FAILED---"
  echo `date`
  exit 1
else
  echo "---Test-argus: TEST PASSED---"
  echo `date`
  exit 0
fi

