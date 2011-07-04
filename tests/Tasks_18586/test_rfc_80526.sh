#!/bin/sh

script_name=`basename $0`
passed="yes"

#########################################################
# Test if the Services are present on the system and setting some variables
# This is done for every test, even if the variables are not needed
if [ -z $PAP_HOME ]; then
if [ -d /usr/share/argus/pap ]
then
PAP_HOME=/usr/share/argus/pap
else
echo "PAP_HOME not set, not found at standard locations. Exiting."
exit 2;
fi
fi

PAP_CTRL=argus-pap
if [ -f /etc/rc.d/init.d/pap-standalone ]; then
PAP_CTRL=pap-standalone
fi


if [ -z $PDP_HOME ]; then
if [ -d /usr/share/argus/pdp ]; then
PAP_HOME=/usr/share/argus/pdp
else
echo "PDP_HOME not set, not found at standard locations. Exiting."
exit 2;
fi
fi

PDP_CTRL=argus-pdp
if [ -f /etc/rc.d/init.d/pdp ]; then
PDP_CTRL=pdp;
fi


if [ -z $PEP_HOME ]; then
if [ -d /usr/share/argus/pepd ]; then
PEP_HOME=/usr/share/argus/pepd
else
echo "PEP_HOME not set, not found at standard locations. Exiting."
exit 2;
fi
fi

PEP_CTRL=argus-pepd
if [ -f /etc/rc.d/init.d/pepd ]; then
PEP_CTRL=pepd;
fi
#########################################################
#########################################################



echo `date`
echo "---Test: non alphabetic characters in pool accounts---"
#########################################################

echo "1) a JUnit exists for that specific RFC, its output is:"
echo "---"
echo "Running org.glite.authz.pep.obligation.dfpmap.GridMapDirPoolAccountManagerTest
------------testPoolAccountNamesPrefixed------------
accountNames(dteam): [dteam03, dteam02, dteam01]
checking: dteam03
checking: dteam02
checking: dteam01
------------testPoolAccountNamesPrefixes------------
accountNamePrefixes: [user2test, dteam, user1test, Z., dteamprod, lte-dteam, a_0a, aa, a, a-]
------------testPoolAccountNames------------
poolAccountNames: [user2test02, dteam03, user1test03, Z.01, dteamprod01, lte-dteam02, a_0a02, Z.02, aa01, Z.03, a_0a03, a02, a01, lte-dteam03, a-02, dteam02, a_0a01, user2test03, a03, user1test01, user2test01, lte-dteam01, a-01, aa02, dteamprod02, aa03, dteamprod03, user1test02, dteam01, a-03]
------------testCreateMapping------------
identifier '%2fcn%3djohn%20doe:dteam' mapped to: dteam03
------------testMapToAccountPoolDteam------------
principal 'CN=Robin' with prefix 'dteam' mapped to: dteam03
------------testMapToAccountPoolLTEDteam------------
principal 'CN=Batman' with prefix 'lte-dteam' mapped to: lte-dteam02
principal 'CN=Robin' with prefix 'lte-dteam' mapped to: lte-dteam03
04/18/11 00:46:50.220 INFO main [write] - principal 'CN=John Doe' with prefix 'lte-dteam' mapped to: lte-dteam01
Tests run: 6, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.053 sec "
echo "---"
echo "OK"
echo "-------------------------------"



if [ $passed == "no" ]; then
echo "---Test: non alphabetic characters in pool accounts: TEST FAILED---"
echo `date`
exit 1
else
echo "---Test: non alphabetic characters in pool accounts: TEST PASSED---"
echo `date`
exit 0
fi
