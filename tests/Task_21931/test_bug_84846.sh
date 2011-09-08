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
echo "---Test: change first lease time-stamp---"
#########################################################

echo "1) a junit exists for this test:"
echo "------------testSubjectIdentifierFileTimestampUpdate------------
BUG FIX: https://savannah.cern.ch/bugs/index.php?83281
BUG FIX: https://savannah.cern.ch/bugs/index.php?84846
09/07/11 14:25:18.308 INFO main [write] - 14:25:18.302 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=Batman with primary group dteam and secondary groups null
09/07/11 14:25:18.411 INFO main [write] - 14:25:18.309 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Checking if grid map account dteam03 may be linked to subject identifier %2fcn%3dbatman:dteam
14:25:18.310 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Linked subject identifier %2fcn%3dbatman:dteam to pool account file dteam03
14:25:18.310 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3dbatman:dteam
14:25:18.310 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - A new account mapping has mapped subject CN=Batman with primary group dteam and secondary groups null to pool account dteam03
Principal 'CN=Batman' with account prefix 'dteam' mapped to: dteam03
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3dbatman:dteam
Lastmodified: 1315398317287 < 1315398318000
09/07/11 14:25:19.331 INFO main [write] - 14:25:19.327 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=Batman with primary group dteam and secondary groups null
14:25:19.329 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3dbatman:dteam
14:25:19.329 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - An existing account mapping has mapped subject CN=Batman with primary group dteam and secondary groups null to pool account dteam03
09/07/11 14:25:19.436 INFO main [write] - Principal 'CN=Batman' with account prefix 'dteam' mapped to: dteam03
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3dbatman:dteam
Lastmodified: 1315398318000 < 1315398319000
09/07/11 14:25:20.345 INFO main [write] - 14:25:20.341 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=Batman with primary group dteam and secondary groups null
14:25:20.343 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3dbatman:dteam
14:25:20.343 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - An existing account mapping has mapped subject CN=Batman with primary group dteam and secondary groups null to pool account dteam03
Principal 'CN=Batman' with account prefix 'dteam' mapped to: dteam03
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3dbatman:dteam
Lastmodified: 1315398319000 < 1315398320000
09/07/11 14:25:21.360 INFO main [write] - 14:25:21.355 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=Robin with primary group dteam and secondary groups null
14:25:21.357 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Checking if grid map account dteam03 may be linked to subject identifier %2fcn%3drobin:dteam
14:25:21.358 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Could not map to account dteam03
14:25:21.358 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Checking if grid map account dteam02 may be linked to subject identifier %2fcn%3drobin:dteam
14:25:21.359 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Linked subject identifier %2fcn%3drobin:dteam to pool account file dteam02
14:25:21.359 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3drobin:dteam
14:25:21.359 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - A new account mapping has mapped subject CN=Robin with primary group dteam and secondary groups null to pool account dteam02
Principal 'CN=Robin' with account prefix 'dteam' mapped to: dteam02
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3drobin:dteam
Lastmodified: 1315398320000 < 1315398321000
09/07/11 14:25:22.378 INFO main [write] - 14:25:22.369 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=Robin with primary group dteam and secondary groups null
09/07/11 14:25:22.488 INFO main [write] - 14:25:22.371 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3drobin:dteam
14:25:22.376 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - An existing account mapping has mapped subject CN=Robin with primary group dteam and secondary groups null to pool account dteam02
Principal 'CN=Robin' with account prefix 'dteam' mapped to: dteam02
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3drobin:dteam
Lastmodified: 1315398321000 < 1315398322000
09/07/11 14:25:23.401 INFO main [write] - 14:25:23.393 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=Robin with primary group dteam and secondary groups null
09/07/11 14:25:23.511 INFO main [write] - 14:25:23.400 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3drobin:dteam
14:25:23.400 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - An existing account mapping has mapped subject CN=Robin with primary group dteam and secondary groups null to pool account dteam02
Principal 'CN=Robin' with account prefix 'dteam' mapped to: dteam02
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3drobin:dteam
Lastmodified: 1315398322000 < 1315398323000
09/07/11 14:25:24.412 INFO main [write] - 14:25:24.407 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=John-John Doe with primary group dteam and secondary groups null
14:25:24.408 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Checking if grid map account dteam03 may be linked to subject identifier %2fcn%3djohn%2djohn%20doe:dteam
14:25:24.409 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Could not map to account dteam03
14:25:24.409 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Checking if grid map account dteam02 may be linked to subject identifier %2fcn%3djohn%2djohn%20doe:dteam
14:25:24.409 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Could not map to account dteam02
14:25:24.410 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Checking if grid map account dteam01 may be linked to subject identifier %2fcn%3djohn%2djohn%20doe:dteam
14:25:24.410 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.createMapping - Linked subject identifier %2fcn%3djohn%2djohn%20doe:dteam to pool account file dteam01
14:25:24.410 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3djohn%2djohn%20doe:dteam
14:25:24.411 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - A new account mapping has mapped subject CN=John-John Doe with primary group dteam and secondary groups null to pool account dteam01
Principal 'CN=John-John Doe' with account prefix 'dteam' mapped to: dteam01
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3djohn%2djohn%20doe:dteam
Lastmodified: 1315398323000 < 1315398324000
09/07/11 14:25:25.421 INFO main [write] - 14:25:25.420 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=John-John Doe with primary group dteam and secondary groups null
09/07/11 14:25:25.531 INFO main [write] - 14:25:25.421 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3djohn%2djohn%20doe:dteam
14:25:25.422 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - An existing account mapping has mapped subject CN=John-John Doe with primary group dteam and secondary groups null to pool account dteam01
Principal 'CN=John-John Doe' with account prefix 'dteam' mapped to: dteam01
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3djohn%2djohn%20doe:dteam
Lastmodified: 1315398324000 < 1315398325000
09/07/11 14:25:26.443 INFO main [write] - 14:25:26.442 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=John-John Doe with primary group dteam and secondary groups null
09/07/11 14:25:26.543 INFO main [write] - 14:25:26.444 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3djohn%2djohn%20doe:dteam
14:25:26.444 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - An existing account mapping has mapped subject CN=John-John Doe with primary group dteam and secondary groups null to pool account dteam01
Principal 'CN=John-John Doe' with account prefix 'dteam' mapped to: dteam01
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3djohn%2djohn%20doe:dteam
Lastmodified: 1315398325000 < 1315398326000
09/07/11 14:25:27.455 INFO main [write] - 14:25:27.454 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=John-John Doe with primary group dteam and secondary groups null
09/07/11 14:25:27.556 INFO main [write] - 14:25:27.480 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3djohn%2djohn%20doe:dteam
14:25:27.480 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - An existing account mapping has mapped subject CN=John-John Doe with primary group dteam and secondary groups null to pool account dteam01
Principal 'CN=John-John Doe' with account prefix 'dteam' mapped to: dteam01
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3djohn%2djohn%20doe:dteam
Lastmodified: 1315398326000 < 1315398327000
09/07/11 14:25:28.497 INFO main [write] - 14:25:28.496 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - Checking if there is an existing account mapping for subject CN=John-John Doe with primary group dteam and secondary groups null
09/07/11 14:25:28.622 INFO main [write] - 14:25:28.498 DEBUG o.g.a.p.o.dfpmap.PosixUtil.touchFile - touch /tmp/gridmapdir7070820142449597792.junit/%2fcn%3djohn%2djohn%20doe:dteam
14:25:28.498 DEBUG o.g.a.p.o.d.GridMapDirPoolAccountManager.mapToAccount - An existing account mapping has mapped subject CN=John-John Doe with primary group dteam and secondary groups null to pool account dteam01
Principal 'CN=John-John Doe' with account prefix 'dteam' mapped to: dteam01
Subject identifier file: /tmp/gridmapdir7070820142449597792.junit/%2fcn%3djohn%2djohn%20doe:dteam
Lastmodified: 1315398327000 < 1315398328000
TEST PASSED"
echo "-------------------------------"



if [ $passed == "no" ]; then
echo "---Test: change first lease time-stamp: TEST FAILED---"
echo `date`
exit 1
else
echo "---Test: change first lease time-stamp: TEST PASSED---"
echo `date`
exit 0
fi

