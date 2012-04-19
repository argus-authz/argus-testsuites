#!/bin/sh

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test
HOSTNAME=`hostname`
hostname -f > /dev/null 2>&1
if [ $? -eq 0 ]
then
    HOSTNAME=`hostname -f`
fi

echo `date`
echo "---Test-PAP-FUNC-1---"

failed="no"



#################################################################
#echo "1) testing required security section"
#$PAP_CTRL stop >>/dev/null 2>&1
#sleep 2
# rm -f $PAP_CONF/$PAP_CONF_INI
# touch $PAP_CONF/$PAP_CONF_INI
#cat <<EOF > $PAP_CONF/$PAP_CONF_INI
#[paps]
## Trusted PAPs will be listed here

#[paps:properties]

#poll_interval = 14400
#ordering = default

#[repository]

#location = $PAP_HOME/repository
#consistency_check = false
#consistency_check.repair = false

#[standalone-service]

#hostname = $HOSTNAME
#port = 8150
#shutdown_port = 8151

#[security]

#certificate = /etc/grid-security/hostcert.pem
#private_key = /etc/grid-security/hostkey.pem

#EOF
#
# What should happen here?
# The re-start of the PAP should fail as there are no
# credentials present! At least they have been commented
# out of the configuration file.
#
#$PAP_CTRL start >>/dev/null 2>&1
#sleep 15
# cat $PAP_CONF/$PAP_CONF_INI
# $PAP_CTRL status
#$PAP_CTRL status | grep -q 'PAP running'
#if [ $? -eq 0 ]; then
#  echo "The PAP is running... should NOT be running."
#  failed="yes"
#  cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
#  echo "FAILED"
#else
#  cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
#  $PAP_CTRL start >>/dev/null
#  sleep 10
#  echo "OK"
#fi

#################################################################
echo "2) testing required poll_interval "
$PAP_CTRL stop >>/dev/null 2>&1
sleep 2
rm -f $PAP_CONF/$PAP_CONF_INI
touch $PAP_CONF/$PAP_CONF_INI
cat <<EOF > $PAP_CONF/$PAP_CONF_INI
[paps]
## Trusted PAPs will be listed here

[paps:properties]

#poll_interval = 14400
ordering = default

[repository]

location = $PAP_HOME/repository
consistency_check = false
consistency_check.repair = false

[standalone-service]

hostname = $HOSTNAME
port = 8150
shutdown_port = 8151

[security]

certificate = /etc/grid-security/hostcert.pem
private_key = /etc/grid-security/hostkey.pem

EOF

$PAP_CTRL start >>/dev/null 2>&1
sleep 15
$PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  echo "FAILED"
  cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
else
  cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
  $PAP_CTRL start >>/dev/null
  sleep 10
  echo "OK"
fi

#################################################################
echo "3) testing syntax error: missing ']'"
$PAP_CTRL stop >>/dev/null 2>&1
sleep 2
rm -f $PAP_CONF/$PAP_CONF_INI
touch $PAP_CONF/$PAP_CONF_INI
cat <<EOF > $PAP_CONF/$PAP_CONF_INI
[paps]
## Trusted PAPs will be listed here

[paps:properties]

poll_interval = 14400
ordering = default

[repository]

location = $PAP_HOME/repository
consistency_check = false
consistency_check.repair = false

[standalone-service

hostname = $HOSTNAME
port = 8150
shutdown_port = 8151

[security]

certificate = /etc/grid-security/hostcert.pem
private_key = /etc/grid-security/hostkey.pem

EOF

$PAP_CTRL start >>/dev/null 2>&1
sleep 15
$PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  echo "FAILED"
  cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
else
  cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
  $PAP_CTRL start >>/dev/null
  sleep 10
  echo "OK"
fi

#################################################################
echo "4) testing syntax error: missing '='"
$PAP_CTRL stop >>/dev/null 2>&1
sleep 2
rm -f $PAP_CONF/$PAP_CONF_INI
touch $PAP_CONF/$PAP_CONF_INI
cat <<EOF > $PAP_CONF/$PAP_CONF_INI
[paps]
## Trusted PAPs will be listed here

[paps:properties]

poll_interval = 14400
ordering = default

[repository]

location = $PAP_HOME/repository
consistency_check = false
consistency_check.repair = false

[standalone-service]

hostname = $HOSTNAME
port = 8150
shutdown_port = 8151

[security]

certificate  /etc/grid-security/hostcert.pem
private_key = /etc/grid-security/hostkey.pem

EOF

$PAP_CTRL start >>/dev/null 2>&1
sleep 15
$PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  echo "FAILED"
  cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
else
  cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
  $PAP_CTRL start >>/dev/null
  sleep 10
  echo "OK"
fi

#################################################################
echo "5) testing argus syntax error: missing ']'"
$PAP_CTRL stop >>/dev/null 2>&1
sleep 2
rm -f $PAP_CONF/$PAP_AUTH_INI
touch $PAP_CONF/$PAP_AUTH_INI
cat <<EOF > $PAP_CONF/$PAP_AUTH_INI
[dn


"/C=CH/O=CERN/OU=GD/CN=Test user 300" : ALL
"/DC=ch/DC=cern/OU=computers/CN=vtb-generic-54.cern.ch" : POLICY_READ_LOCAL|POLICY_READ_REMOTE


[fqan]

EOF

$PAP_CTRL start >>/dev/null 2>&1
sleep 10
$PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  echo "FAILED"
  cp -f $SCRIPTBACKUPLOCATION/$PAP_AUTH_INI $PAP_CONF/$PAP_AUTH_INI
else
  cp -f $SCRIPTBACKUPLOCATION/$PAP_AUTH_INI $PAP_CONF/$PAP_AUTH_INI
  $PAP_CTRL start >>/dev/null
  sleep 10
  echo "OK"
fi

#################################################################
echo "6) testing argus syntax error: missing ':'"
$PAP_CTRL stop >>/dev/null 2>&1
sleep 2
rm -f $PAP_CONF/$PAP_AUTH_INI
touch $PAP_CONF/$PAP_AUTH_INI
cat <<EOF > $PAP_CONF/$PAP_AUTH_INI
[dn]


"/C=CH/O=CERN/OU=GD/CN=Test user 300"  ALL
"/DC=ch/DC=cern/OU=computers/CN=vtb-generic-54.cern.ch" : POLICY_READ_LOCAL|POLICY_READ_REMOTE


[fqan]

EOF

$PAP_CTRL start >>/dev/null 2>&1
sleep 10
$PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  echo "FAILED"
  cp -f $SCRIPTBACKUPLOCATION/$PAP_AUTH_INI $PAP_CONF/$PAP_AUTH_INI
else
  cp -f $SCRIPTBACKUPLOCATION/$PAP_AUTH_INI $PAP_CONF/$PAP_AUTH_INI
  $PAP_CTRL start >>/dev/null
  sleep 10
  echo "OK"
fi

#################################################################
echo "7) testing argus syntax error: missing 'permission'"
$PAP_CTRL stop >>/dev/null 2>&1
sleep 2
rm -f $PAP_CONF/$PAP_AUTH_INI
touch $PAP_CONF/$PAP_AUTH_INI
cat <<EOF > $PAP_CONF/$PAP_AUTH_INI
[dn]


"/C=CH/O=CERN/OU=GD/CN=Test user 300"
"/DC=ch/DC=cern/OU=computers/CN=vtb-generic-54.cern.ch" : POLICY_READ_LOCAL|POLICY_READ_REMOTE


[fqan]

EOF

$PAP_CTRL start >>/dev/null 2>&1
sleep 10
$PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  echo "FAILED"
  cp -f $SCRIPTBACKUPLOCATION/$PAP_AUTH_INI $PAP_CONF/$PAP_AUTH_INI
else
  cp -f $SCRIPTBACKUPLOCATION/$PAP_AUTH_INI $PAP_CONF/$PAP_AUTH_INI
  $PAP_CTRL start >>/dev/null
  sleep 10
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
  echo "---Test-PAP-FUNC-1: TEST FAILED---"
  echo `date`
  exit 1
else
  echo "---Test-PAP-FUNC-1: TEST PASSED---"
  echo `date`
  exit 0
fi

