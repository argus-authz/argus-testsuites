#!/bin/sh

script_name=`basename $0`
passed="yes"

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh



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
source_dir=/etc/grid-security
target_file=grid-mapfile
touch ${source_dir}/${target_file}

target_file=groupmapfile
touch ${source_dir}/${target_file}

target_file_dir=gridmapdir
mkdir -p ${target_dir}/${target_file_dir}

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
