#!/bin/sh

# Make sure that a test finds a virgin environment

# Stop
$PAP_CTRL stop > /dev/null 2>&1
$PDP_CTRL stop > /dev/null 2>&1
$PEP_CTRL stop > /dev/null 2>&1

# Get clean backuped version of the configuration-scripts
if [ -z "$SCRIPTBACKUPLOCATION" ]; then
    mkdir -p $SCRIPTBACKUPLOCATION 
fi

if [ ! -d $SCRIPTBACKUPLOCATION ];then
    echo   "Error while creating backup directory $SCRIPTBACKUPLOCATION"
    return 1
else
    echo "Backup files will be stored in $SCRIPTBACKUPLOCATION"
    cp -f $SCRIPTBACKUPLOCATION/$PDP_INI $PDP_CONF/$PDP_INI
    cp -f $SCRIPTBACKUPLOCATION/$PEP_INI $PEP_CONF/$PEP_INI
    cp -f $SCRIPTBACKUPLOCATION/$PAP_ADMIN_INI $PAP_CONF/$PAP_ADMIN_INI
    cp -f $SCRIPTBACKUPLOCATION/$PAP_AUTH_INI $PAP_CONF/$PAP_AUTH_INI
    cp -f $SCRIPTBACKUPLOCATION/$PAP_CONF_INI $PAP_CONF/$PAP_CONF_INI
fi

# Start the services
$PAP_CTRL start > /dev/null 2>&1
$PDP_CTRL start > /dev/null 2>&1
$PEP_CTRL start > /dev/null 2>&1

# Bridge a possible startup delay (e.g. to open up ports)
sleep 5

# Remove all policies from the PAP, a test has to define own policies if needed
$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: ${PAP_HOME}/bin/pap-admin rap"
  return 1
fi

# Make sure the clean state is propagated troughout Argus
$PDP_CTRL reloadpolicy > /dev/null 2>&1
$PEP_CTRL clearcache > /dev/null 2>&1