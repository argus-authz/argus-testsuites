#!/bin/bash

# Make sure that a test finds a virgin environment

# Stop
echo "Stop PAP..."
$T_PAP_CTRL stop 
echo "Stop PDP..."
$T_PDP_CTRL stop
echo "Stop PEP Server..."
$T_PEP_CTRL stop

sleep 2

# Get clean backuped version of the configuration-scripts
if [ ! -d $SCRIPTBACKUPLOCATION ];then
    echo   "Error no backup directory found at $SCRIPTBACKUPLOCATION, exiting"
    return 1
else
    echo "Retrieving backup files from in $SCRIPTBACKUPLOCATION"
    cp -f $SCRIPTBACKUPLOCATION/$T_PDP_INI $T_PDP_CONF/$T_PDP_INI
    cp -f $SCRIPTBACKUPLOCATION/$T_PEP_INI $T_PEP_CONF/$T_PEP_INI
    cp -f $SCRIPTBACKUPLOCATION/$T_PAP_ADMIN_INI $T_PAP_CONF/$T_PAP_ADMIN_INI
    cp -f $SCRIPTBACKUPLOCATION/$T_PAP_AUTH_INI $T_PAP_CONF/$T_PAP_AUTH_INI
    cp -f $SCRIPTBACKUPLOCATION/$T_PAP_CONF_INI $T_PAP_CONF/$T_PAP_CONF_INI
    cp -f $SCRIPTBACKUPLOCATION/$GRID_MAPFILE $GRIDDIR/$GRID_MAPFILE
    cp -f $SCRIPTBACKUPLOCATION/$GROUPMAPFILE $GRIDDIR/$GROUPMAPFILE
    mkdir -p $GRIDDIR/$GRIDMAPDIR
    cp -f $SCRIPTBACKUPLOCATION/$GRIDMAPDIR/* $GRIDDIR/$GRIDMAPDIR/
fi

sleep 2

# Start the services
echo "Start PAP..."
$T_PAP_CTRL start 
echo "Start PDP..."
$T_PDP_CTRL start
echo "Start PEP Server..."
$T_PEP_CTRL start

# Bridge a possible startup delay (e.g. to open up ports)
sleep 10

# Remove all policies from the PAP, a test has to define own policies if needed
echo "Removing all stored policies from the PAP..."
$T_PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: ${T_PAP_HOME}/bin/pap-admin rap"
  return 1
fi

# Make sure the clean state is propagated troughout Argus
echo "PDP reload policies..."
$T_PDP_CTRL reloadpolicy 
echo "PEP Server clear cache..."
$T_PEP_CTRL clearcache 

echo "done"
return 0
