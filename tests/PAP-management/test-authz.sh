#!/bin/bash

#Assumtpions: The PAP is running with a correct configuration file
#Note: Each single test has this assumption

echo `date`
echo "---Test-argus---"

if [ -z $T_PAP_HOME ]
then
    if [ -d /usr/share/argus/pap ]
    then
        T_PAP_HOME=/usr/share/argus/pap
    else
        if [ -d /opt/argus/pap ]
        then
            T_PAP_HOME=/opt/argus/pap
        else
            echo "T_PAP_HOME not set, not found at standard locations. Exiting."
            exit 2;
        fi
    fi
fi
T_PAP_CTRL=argus-pap
if [ -f /etc/rc.d/init.d/pap-standalone ]
then
    T_PAP_CTRL=pap-standalone
fi
echo "T_PAP_CTRL set to: /etc/rc.d/init.d/$T_PAP_CTRL"
/etc/rc.d/init.d/$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  /etc/rc.d/init.d/$T_PAP_CTRL start
  sleep 10
fi
argusconffile=$T_PAP_HOME/conf/pap_authorization.ini
argusbkpfile=/tmp/pap_authorization.bkp
failed="no"


/etc/rc.d/init.d/$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  exit 1
fi

#################################################################
echo "1) testing lp with no authorization"
mv -f $argusconffile  $argusbkpfile

cat <<EOF > $argusconffile
# Configuration file created by YAIM
[dn]
ANYONE : CONFIGURATION_READ
[fqan]
EOF

/etc/rc.d/init.d/$T_PAP_CTRL stop >>/dev/null
sleep 5
/etc/rc.d/init.d/$T_PAP_CTRL start >>/dev/null
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
mv -f $argusbkpfile $argusconffile
/etc/rc.d/init.d/$T_PAP_CTRL status | grep -q 'PAP not running'
if [ $? -eq 0 ]; then
  /etc/rc.d/init.d/$T_PAP_CTRL start >>/dev/null
else
    /etc/rc.d/init.d/$T_PAP_CTRL stop >>/dev/null
    sleep 5
    /etc/rc.d/init.d/$T_PAP_CTRL start >>/dev/null
fi
sleep 10

#################################################################
echo "2) testing lp with anyone full power"
mv -f $argusconffile  $argusbkpfile

cat <<EOF > $argusconffile
# Configuration file created by YAIM
[dn]
ANYONE : ALL
[fqan]
EOF

/etc/rc.d/init.d/$T_PAP_CTRL stop >>/dev/null
sleep 5
/etc/rc.d/init.d/$T_PAP_CTRL start >>/dev/null
sleep 10
$T_PAP_HOME/bin/pap-admin lp >>/dev/null
if [ $? -ne 0 ]; then
  failed="yes"
  echo "FAILED"
else
  echo "OK"
fi

#################################################################
#start/restart the server
mv -f $argusbkpfile $argusconffile
/etc/rc.d/init.d/$T_PAP_CTRL status | grep -q 'PAP not running'
if [ $? -eq 0 ]; then
  /etc/rc.d/init.d/$T_PAP_CTRL start >>/dev/null
else
    /etc/rc.d/init.d/$T_PAP_CTRL stop >>/dev/null
    sleep 5
    /etc/rc.d/init.d/$T_PAP_CTRL start >>/dev/null
fi
sleep 10

if [ $failed == "yes" ]; then
  echo "---Test-argus: TEST FAILED---"
  echo `date`
  exit 1
else
  echo "---Test-argus: TEST PASSED---"
  echo `date`
  exit 0
fi

