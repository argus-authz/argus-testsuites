#!/bin/sh

script_name=`basename $0`
passed="yes"

#########################################################
# Test if the Services are present on the system and setting some variables
# This is done for every test, even if the variables are not needed
if [ -z $PAP_HOME ]; then
	if [ -d /usr/share/argus/pap ]; then
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
		PDP_HOME=/usr/share/argus/pdp
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
# Prepare the environment (conf-files, e.t.c) for the TEST
#
is_proxy="yes"

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
	'"dteam" "voms.hellasgrid.gr" "15004" "/C=GR/O=HellasGrid/OU=hellasgrid.gr/CN=voms.hellasgrid.gr" "dteam"'\
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
# "/dteam" .dteam
# <DN> <user id>
target_file=/etc/grid-security/grid-mapfile
DTEAM=.dteam
echo '"/dteam"' $DTEAM > ${target_file}
echo '"/dteam/Role=NULL/Capability=NULL"' $DTEAM > ${target_file}
echo ${target_file};cat ${target_file}

target_file=/etc/grid-security/groupmapfile
DTEAM=DTEAM-Group
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
	/etc/rc.d/init.d/$PEP_CTRL status > /dev/null
	if [ $? -ne 0 ]; then
		echo "PEPd is not running. Starting one."
  		/etc/rc.d/init.d/$PEP_CTRL start
  		sleep 10
	else
  		echo "${script_name}: Stopping PEPd."
  		/etc/rc.d/init.d/$PEP_CTRL stop > /dev/null
  		sleep 5
  		echo "${script_name}: Starting PEPd."
  		/etc/rc.d/init.d/$PEP_CTRL start > /dev/null
  		sleep 15
	fi
}
pep_start

function pdp_start {
	/etc/rc.d/init.d/$PDP_CTRL status > /dev/null
	if [ $? -ne 0 ]; then
		echo "PDP is not running. Starting one."
		/etc/rc.d/init.d/$PDP_CTRL start
  		sleep 10
	fi
}
pdp_start

function pap_start {
	/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP running'
	if [ $? -ne 0 ]; then
  		echo "PAP is not running"
  		/etc/rc.d/init.d/$PAP_CTRL start;
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
# so should match the first "subject= " and keep the rest
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

$PAP_HOME/bin/pap-admin ap $RULE subject="${obligation_dn}" \
			 --resource $RESOURCE \
             --action $ACTION \
             --obligation $OBLIGATION 
             
sleep 5;

/etc/rc.d/init.d/$PEP_CTRL clearcache
/etc/rc.d/init.d/$PDP_CTRL reloadpolicy #without this, the policy wouldn't be visible for ~5min.
#########################################################


#########################################################
# Now everything is set up and we can start the test
echo `date`
echo "---Test: legacy LCAS/LCMAPS lease filename encoding---"

echo "1) test if groupnames containing capitals and/or hyphen are encoded the right way:"

pepcli --pepd https://`hostname`:8154/authz \
       -c /tmp/x509up_u0 \
       --capath /etc/grid-security/certificates/ \
       --key $USERKEY \
       --cert $USERCERT \
       --resource $RESOURCE \
       --keypasswd $USERPWD \
       --action $ACTION > /dev/null
       
ls  /etc/grid-security/gridmapdir/ | grep $DTEAM

if [ $? -ne 0 ]; then
	passed="no";
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
	echo "---Test: legacy LCAS/LCMAPS lease filename encoding TEST FAILED--"
	echo `date`
	exit 1
else
	echo "---Test: legacy LCAS/LCMAPS lease filename encoding TEST PASSED---"
	echo `date`
	exit 0
fi
