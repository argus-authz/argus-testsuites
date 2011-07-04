#!/bin/bash

#Assumtpions: The PEP is running with a correct configuration file
#Note: Each single test has this assumption

#Set the Home directory according the installation type (EMI or Glite)
if [ -z $PEP_HOME ]
then
if [ -d /usr/share/argus/pepd ]
then
PEP_HOME=/usr/share/argus/pepd
else
if [ -d /opt/argus/pepd ]
then
PEP_HOME=/opt/argus/pepd
else
echo "PEP_HOME not set, not found at standard locations. Exiting."
exit 2;
fi
fi
fi

#Set the Process name according the installation type (EMI or Glite)
PEP_CTRL=argus-pepd
if [ -f /etc/rc.d/init.d/pepd ]
then
PEP_CTRL=pepd;
fi
echo "PEP_CTRL set to: $PEP_CTRL"

#Set the Status info according the installation type (EMI or Glite)
PEP_INFO='Argus PEP Server'
if [ "$PEP_CTRL" = "pepd" ]
then
PEP_INFO=pepd;
fi
echo "PEP_INFO set to: $PEP_INFO"

echo `date`
echo "---Test-PEP-Configuration---"

conffile=$PEP_HOME/conf/pepd.ini
bkpconffile=$PEP_HOME/conf/pepd.bkp
bkpconffile2=$PEP_HOME/conf/pepd.bkp2
failed="no"

#################################################################
echo "1) testing pep status"

/etc/rc.d/init.d/$PEP_CTRL status | grep -q "service: $PEP_INFO"
if [ $? -eq 0 ]; then
echo "OK"
else
failed="yes"
echo "Failed"
fi

#################################################################
echo "2) testing pep with SSL"
/etc/rc.d/init.d/$PEP_CTRL stop
sleep 5
mv $conffile $bkpconffile
#Insert SSL option
sed '/SERVICE/a\enableSSL = true' $bkpconffile > $conffile

/etc/rc.d/init.d/$PEP_CTRL start
sleep 5
if [ $? -eq 0 ]
then
echo "OK"
else
failed="yes"
echo "Failed"
fi

#################################################################

if [ "$PEP_INFO" = "Argus PEP Server" ]
then
echo "3) testing pep with no config file"
/etc/rc.d/init.d/$PEP_CTRL stop
sleep 5
mv $conffile $bkpconffile2
/etc/rc.d/init.d/$PEP_CTRL start
if [ $? -ne 0 ] 
then
sleep 5
echo "OK"
else
failed="yes"
echo "Failed"
fi
fi

#################################################################

mv $bkpconffile $conffile
rm -f $bkpconffile2
/etc/rc.d/init.d/$PEP_CTRL stop >>/dev/null
sleep 5
/etc/rc.d/init.d/$PEP_CTRL start >>/dev/null
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

