#!/bin/bash

script_name=`basename $0`
failed="no"
policyfile=policyfile.txt
obligationfile=obligationfile.txt


pep_config="$T_PEP_HOME/conf/pepd.ini"
pep_config_saved="/tmp/pepd.ini.saved"

## To here for EGEE/EMI compatible tests


USERCERT=~/user_certificates/test_user_1_cert.pem
USERKEY=~/user_certificates/test_user_1_key.pem
USERPWD=`cat ~/user_certificates/password`

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
    export PATH=$PATH:/opt/glite/bin/
    export LD_LIBRARY_PATH=/opt/glite/lib64
    voms-proxy-init -voms dteam \
    -cert $USERCERT \
    -key $USERKEY \
    -pwstdin < ~/user_certificates/password
    CMD="voms-proxy-info -fqan"; echo $CMD; $CMD
    if [ $? -eq 0 ]; then
        USERCERT=$USERPROXY
    else
        echo "Error setting the Usercert to $USERPROXY"
    fi
fi

echo "Running: ${script_name}"
echo `date`

# Get my cert DN for usage later
#
# Here's the string format
# subject= /C=CH/O=CERN/OU=GD/CN=Test user 1
# so should match the first "subject= " and keep the rest
# of the string
#

foo=`openssl x509 -in $USERCERT -subject -noout`
obligation_dn=`echo $foo | sed 's/subject= //'`
echo " subject string = $obligation_dn"



# Next remove all the "leases" from the /etc/grid-security/gridmapdir/
# This may not be the best method below... but OK.

rm /etc/grid-security/gridmapdir/*`hostname`* > /dev/null 2>&1

# Copy the files:
# /etc/grid-security/grid-mapfile
# /etc/grid-security/groupmapfile
# /etc/grid-security/voms-grid-mapfile
# To /tmp directory for safekeeping?

target_dir="/tmp/"
source_dir="/etc/grid-security"
target_file="grid-mapfile"
cp ${source_dir}/${target_file} ${target_dir}/${target_file}.${script_name}
target_file="voms-grid-mapfile"
cp ${source_dir}/${target_file} ${target_dir}/${target_file}.${script_name}
target_file="groupmapfile"
cp ${source_dir}/${target_file} ${target_dir}/${target_file}.${script_name}

# Now enter the userids etc
# /etc/grid-security/grid-mapfile
# "/dteam" .dteam
# <DN> <user id>

target_file=/etc/grid-security/grid-mapfile
DTEAM=".dteam"
DN_UID="glite"
echo \"/dteam\" ${DTEAM} > ${target_file}
echo \"${obligation_dn}\" ${DN_UID} >> ${target_file} #"
echo ${target_file};cat ${target_file}

target_file=/etc/grid-security/groupmapfile
DTEAM="dteam"
DN_UID_GROUP="testing"
echo \"/dteam\" ${DTEAM} > ${target_file} #"
echo ${target_file};cat ${target_file}

# Now sort out the pepd.ini file
grep -q 'org.glite.authz.pep.obligation.dfpmap.DFPMObligationHandlerConfigurationParser' $T_PEP_CONF/$T_PEP_INI
if [ $? -ne 0 ]; then
    echo "${script_name}: Obligation handler not defined"
    failed="yes"
    exit 1;
fi
preferDNForLoginName="preferDNForLoginName = false"
preferDNForPrimaryGroupName="preferDNForPrimaryGroupName = false"
noPrimaryGroupNameIsError="noPrimaryGroupNameIsError = true"

echo $preferDNForLoginName      >> $T_PEP_CONF/$T_PEP_INI; echo $preferDNForLoginName
echo $noPrimaryGroupNameIsError >> $T_PEP_CONF/$T_PEP_INI; echo $noPrimaryGroupNameIsError
echo $preferDNForPrimaryGroupName >> $T_PEP_CONF/$T_PEP_INI; echo $preferDNForPrimaryGroupName

# Now probably should start the services and test whether I can get an account.

function pep_start {
$T_PEP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
  echo "PEPd is not running. Starting one."
  $T_PEP_CTRL start
  sleep 10
else
  echo "${script_name}: Restarting PEPd."
  $T_PEP_CTRL restart > /dev/null
  sleep 10
fi
}

pep_start

function pdp_start {
$T_PDP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
  echo "PDP is not running. Starting one."
  $T_PDP_CTRL start
  sleep 10
fi
}

pdp_start

# use a PAP to enter a policy and an obligation?

function pap_start {
$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  $T_PAP_CTRL start;
  sleep 10;
fi 
}

pap_start

# Remove all policies defined for the default pap
$PAP_ADMIN rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $T_PAP_HOME/bin/pap-admin rap"
  exit 1
fi

RESOURCE="resource_1"
ACTION="do_not_test"
RULE="permit"
OBLIGATION="http://glite.org/xacml/obligation/local-environment-map"

# Now should add the obligation?
$PAP_ADMIN ap --resource resource_1 \
             --action testwerfer \
             --obligation $OBLIGATION ${RULE} subject="${obligation_dn}"


###############################################################

$T_PDP_CTRL reloadpolicy

###############################################################