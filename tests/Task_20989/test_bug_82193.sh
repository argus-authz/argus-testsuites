#!/bin/sh

script_name=`basename $0`
passed="yes"

#########################################################
# Test if the Services are present on the system and setting some variables
# This is done for every test, even if the variables are not needed
if [ -z $T_PAP_HOME ]; then
	if [ -d /usr/share/argus/pap ]; then
		T_PAP_HOME=/usr/share/argus/pap
	else
		echo "T_PAP_HOME not set, not found at standard locations. Exiting."
		exit 2;
	fi
fi

T_PAP_CTRL=argus-pap
if [ -f /etc/rc.d/init.d/pap-standalone ]; then
	T_PAP_CTRL=pap-standalone
fi


if [ -z $T_PDP_HOME ]; then
	if [ -d /usr/share/argus/pdp ]; then
		T_PDP_HOME=/usr/share/argus/pdp
	else
		echo "T_PDP_HOME not set, not found at standard locations. Exiting."
		exit 2;
	fi
fi

T_PDP_CTRL=argus-pdp
if [ -f /etc/rc.d/init.d/pdp ]; then
	T_PDP_CTRL=pdp;
fi


if [ -z $T_PEP_HOME ]; then
	if [ -d /usr/share/argus/pepd ]; then
		T_PEP_HOME=/usr/share/argus/pepd
	else
		echo "T_PEP_HOME not set, not found at standard locations. Exiting."
		exit 2;
	fi
fi

T_PEP_CTRL=argus-pepd
if [ -f /etc/rc.d/init.d/pepd ]; then
	T_PEP_CTRL=pepd;
fi
#########################################################


#########################################################
# Prepare the environment (conf-files, e.t.c) for the TEST
#
is_proxy=”yes”

if [ $is_proxy ]; then
	USERCERT=~/user_certificates/test_user_1_cert.pem
	USERKEY=~/user_certificates/test_user_1_key.pem
	USERPWD=`cat ~/user_certificates/password`
else
	USERCERT=/etc/grid-security/hostcert.pem
	USERKEY=/etc/grid-security/hostkey.pem
fi

if [ ! -d /etc/vomses ]; then
	mkdir -p /etc/vomses
fi

if [ ! -f /etc/vomses/dteam-voms.cern.ch ]; then
	echo \
	‘“dteam” “voms.hellasgrid.gr” “15004” “/C=GR/O=HellasGrid/OU=hellasgrid.gr/CN=voms.hellasgrid.gr” “dteam”’\
	> /etc/vomses/dteam-voms.cern.ch
fi

USERPROXY=/tmp/x509up_u0
rm $USERPROXY

if [ ! -f $USERPROXY ]; then
	voms-proxy-init -voms dteam \
	-cert $USERCERT \
	-key $USERKEY \
	-pwstdin < ~/user_certificates/password
	voms-proxy-info -fqan
fi



# Copy the files:
# /etc/grid-security/grid-mapfile
# /etc/grid-security/groupmapfile
# and the directory:
# /etc/grid-security/gridmapdir
# To /tmp directory for safekeeping!
target_dir=/tmp
source_dir=/etc/grid-security
target_file=grid-mapfile
mv ${source_dir}/${target_file} ${target_dir}/${target_file}.${script_name}
touch ${source_dir}/${target_file}

target_file=groupmapfile
mv ${source_dir}/${target_file} ${target_dir}/${target_file}.${script_name}
touch ${source_dir}/${target_file}

target_file_dir=gridmapdir
tar -cf ${target_dir}/${target_file_dir}.tar  ${source_dir}/${target_file_dir} --remove-files

# Now enter the userids etc
# /etc/grid-security/grid-mapfile
# “/dteam” .dteam
# <DN> <user id>
target_file=/etc/grid-security/grid-mapfile
DTEAM=.dteam
echo '"/dteam"' $DTEAM > ${target_file}
echo '"/dteam/Role=NULL/Capability=NULL"' $DTEAM > ${target_file}
echo ${target_file};cat ${target_file}

target_file=/etc/grid-security/groupmapfile
DTEAM=dteam
echo '"/dteam"' $DTEAM > ${target_file}
echo '"/dteam/Role=NULL/Capability=NULL"' $DTEAM > ${target_file}
echo ${target_file};cat ${target_file}

# make sure that there is a reference to the glite pool-accounts in the gridmapdir
touch /etc/grid-security/gridmapdir/dteam001
touch /etc/grid-security/gridmapdir/dteam002


#########################################################


#########################################################
# Now probably let's start the services.
function pep_start {
	/etc/rc.d/init.d/$T_PEP_CTRL status > /dev/null
	if [ $? -ne 0 ]; then
		echo "PEPd is not running. Starting one."
  		/etc/rc.d/init.d/$T_PEP_CTRL start
  		sleep 10
	else
  		echo "${script_name}: Stopping PEPd."
  		/etc/rc.d/init.d/$T_PEP_CTRL stop > /dev/null
  		sleep 5
  		echo "${script_name}: Starting PEPd."
  		/etc/rc.d/init.d/$T_PEP_CTRL start > /dev/null
  		sleep 15
	fi
}
pep_start

function pdp_start {
	/etc/rc.d/init.d/$T_PDP_CTRL status > /dev/null
	if [ $? -ne 0 ]; then
		echo "PDP is not running. Starting one."
		/etc/rc.d/init.d/$T_PDP_CTRL start
  		sleep 10
	fi
}
pdp_start

function pap_start {
	/etc/rc.d/init.d/$T_PAP_CTRL status | grep -q 'PAP running'
	if [ $? -ne 0 ]; then
  		echo "PAP is not running"
  		/etc/rc.d/init.d/$T_PAP_CTRL start;
  		sleep 10;
	fi 
}
pap_start
#########################################################


#########################################################
# Get my cert DN for usage later
#
# Here’s the string format
# subject= /C=CH/O=CERN/OU=GD/CN=Test user 1
# so should match the first “subject= “ and keep the rest
# of the string
obligation_dn=`openssl x509 -in $USERCERT -subject -noout -nameopt RFC2253 | sed 's/subject= //'`
echo subject string="$obligation_dn"
#########################################################


#########################################################
# Now its time to define a policy and add it with pap-admin
RESOURCE=test_resource
ACTION=ANY
RULE=permit
OBLIGATION="http://glite.org/xacml/obligation/local-environment-map"

$T_PAP_HOME/bin/pap-admin ap $RULE subject="${obligation_dn}" \
			 --resource $RESOURCE \
             --action $ACTION \
             --obligation $OBLIGATION 
             
sleep 5;

/etc/rc.d/init.d/$T_PEP_CTRL clearcache
/etc/rc.d/init.d/$T_PDP_CTRL reloadpolicy #without this, the policy wouldn't be visible for ~5min.
#########################################################


#########################################################
# Now everything is set up and we can start the test
echo `date`
echo "---Test: Pap-admin aace CN=.../... causes Pap-crash at restart---"

echo "1) test if Pap restart after a kerberized DN was added as acl:"

FAKE_KERB_DN="/CN=host/argus.example.ch/C=CH"
$T_PAP_HOME/bin/pap-admin aace $FAKE_KERB_DN ALL
echo "added a kerberized DN to pap"
sleep 10
/etc/rc.d/init.d/$T_PAP_CTRL restart;
echo "Pap-restarted ..."
sleep 10;
$T_PAP_HOME/bin/pap-admin lp > /dev/null
if [ $? -ne 0 ]; then
	passed="no";
  	echo "PAP crashed"
else
	echo "Succesfull"
	$T_PAP_HOME/bin/pap-admin race $FAKE_KERB_DN
fi 
echo "-------------------------------"
#########################################################


#########################################################
#
# clean up...
#
# Make sure to return the files
source_dir=/tmp
target_dir=/etc/grid-security
target_file=grid-mapfile
cp ${source_dir}/${target_file}.${script_name} ${target_dir}/${target_file}
target_file=groupmapfile
cp ${source_dir}/${target_file}.${script_name} ${target_dir}/${target_file}
target_file_dir=gridmapdir
rm -f ${target_dir}/${target_file_dir}/*
tar -xf ${source_dir}/${target_file_dir}.tar -C /
#########################################################


#########################################################
# give out wether the test has been passed
if [ $passed == "no" ]; then
	echo "---Test: Pap-admin aace CN=.../... causes Pap-crash at restart---TEST FAILED"
	echo `date`
	exit 1
else
	echo "---Test: Pap-admin aace CN=.../... causes Pap-crash at restart---TEST PASSED"
	echo `date`
	exit 0
fi
