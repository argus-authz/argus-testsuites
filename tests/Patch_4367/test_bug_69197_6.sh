#!/bin/sh

script_name=`basename $0`
failed="no"
policyfile=policyfile.txt
obligationfile=obligationfile.txt

## This is the needed bit to make EGEE/EMI compatible tests
if [ -z $PAP_HOME ]
then
if [ -d /usr/share/argus/pap ]
then
PAP_HOME=/usr/share/argus/pap
else
if [ -d /opt/argus/pap ]
then
PAP_HOME=/opt/argus/pap
else
echo "PAP_HOME not set, not found at standard locations. Exiting."
exit 2;
fi
fi
fi

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


PEP_CTRL=argus-pepd
if [ -f /etc/rc.d/init.d/pepd ];then PEP_CTRL=pepd;fi
echo "PEP_CTRL set to: /etc/rc.d/init.d/$PEP_CTRL"
PDP_CTRL=argus-pdp
if [ -f /etc/rc.d/init.d/pdp ];then PDP_CTRL=pdp;fi
echo "PDP_CTRL set to: /etc/rc.d/init.d/$PDP_CTRL"
PAP_CTRL=argus-pap
if [ -f /etc/rc.d/init.d/pap-standalone ];then
PAP_CTRL=pap-standalone
fi
echo "PAP_CTRL set to: /etc/rc.d/init.d/$PAP_CTRL"
/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
echo "PAP is not running"
/etc/rc.d/init.d/$PAP_CTRL start
sleep 10
fi

PEPCLI=pepcli
if [ -f /opt/glite/bin/pepcli ];then PEPCLI=/opt/glite/bin/pepcli;fi
echo "pepcli command used as: $PEPCLI"

pep_config="$PEP_HOME/conf/pepd.ini"
pep_config_saved="/tmp/pepd.ini.saved"

## To here for EGEE/EMI compatible tests

is_proxy=""
is_proxy="yes"

if [ $is_proxy ]
then
USERCERT=~/user_certificates/test_user_1_cert.pem
USERKEY=~/user_certificates/test_user_1_key.pem
USERPWD=`cat ~/user_certificates/password`
else
USERCERT=/etc/grid-security/hostcert.pem
USERKEY=/etc/grid-security/hostkey.pem
fi

if [ ! -d /etc/vomses ]
then
mkdir -p /etc/vomses
fi

if [ ! -f /etc/vomses/dteam-voms.cern.ch ]
then
echo \
'"dteam" "voms.hellasgrid.gr" "15004" "/C=GR/O=HellasGrid/OU=hellasgrid.gr/CN=voms.hellasgrid.gr" "dteam"'\
> /etc/vomses/dteam-voms.cern.ch
fi

USERPROXY=/tmp/x509up_u0
rm $USERPROXY

if [ ! -f $USERPROXY ]
then
export PATH=$PATH:/opt/glite/bin/
export LD_LIBRARY_PATH=/opt/glite/lib64
voms-proxy-init -voms dteam \
-cert $USERCERT \
-key $USERKEY \
-pwstdin < ~/user_certificates/password
CMD="voms-proxy-info -fqan"; echo $CMD; $CMD
fi

# USERCERT=$HOME/user_certificates/test_user_0_cert.pem
# USERKEY=$HOME/user_certificates/test_user_0_key.pem

X509_USER_CERT=$USERCERT
X509_USER_KEY=$USERKEY

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
echo \"${obligation_dn}\" ${DN_UID} >> ${target_file}
echo; echo ${target_file};echo;cat ${target_file}

target_file=/etc/grid-security/groupmapfile
DTEAM="dteam"
DN_UID_GROUP="testing"
echo \"/dteam\" ${DTEAM} > ${target_file}
echo; echo ${target_file};echo;cat ${target_file}

# Now sort out the pepd.ini file
#
# pep_config="/opt/argus/pepd/conf/pepd.ini"
# pep_config_saved="/tmp/pepd.ini.saved"
cp ${pep_config} ${pep_config_saved}

grep -q 'org.glite.authz.pep.obligation.dfpmap.DFPMObligationHandlerConfigurationParser' ${pep_config}
if [ $? -ne 0 ]
then
    echo "${script_name}: Obligation handler not defined"
    failed="yes"
    exit 1;
fi
echo; echo ${pep_config}; echo;
preferDNForLoginName="preferDNForLoginName = false"
preferDNForPrimaryGroupName="preferDNForPrimaryGroupName = true"
noPrimaryGroupNameIsError="noPrimaryGroupNameIsError = true"

echo $preferDNForLoginName      >> ${pep_config}; echo $preferDNForLoginName
echo $noPrimaryGroupNameIsError >> ${pep_config}; echo $noPrimaryGroupNameIsError
echo $preferDNForPrimaryGroupName >> ${pep_config}; echo $preferDNForPrimaryGroupName

# Now probably should start the services and test whether I can get an account.

function pep_start {
/etc/rc.d/init.d/$PEP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
  echo "PEPd is not running. Starting one."
  /etc/rc.d/init.d/$PEP_CTRL start
  sleep 3
else
  echo "${script_name}: Stopping PEPd."
  /etc/rc.d/init.d/$PEP_CTRL stop > /dev/null
  sleep 3
  echo "${script_name}: Starting PEPd."
  /etc/rc.d/init.d/$PEP_CTRL start > /dev/null
  sleep 3
fi
}

pep_start

function pdp_start {
/etc/rc.d/init.d/$PDP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
  echo "PDP is not running. Starting one."
  /etc/rc.d/init.d/$PDP_CTRL start
  sleep 5
fi
}

pdp_start

# use a PAP to enter a policy and an obligation?

function pap_start {
/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  /etc/rc.d/init.d/$PAP_CTRL start;
  sleep 5;
fi 
}

pap_start

# Remove all policies defined for the default pap
$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_HOME/bin/pap-admin rap"
  exit 1
fi

RESOURCE="resource_1"
ACTION="do_not_test"
RULE="permit"
OBLIGATION="http://glite.org/xacml/obligation/local-environment-map"

# Now should add the obligation?

OPTS=" -v "
OPTS=" "

$PAP_HOME/bin/pap-admin $OPTS ap --resource resource_1 \
             --action testwerfer \
             --obligation $OBLIGATION ${RULE} subject="${obligation_dn}"

$PAP_HOME/bin/pap-admin lp -srai

###############################################################

/etc/rc.d/init.d/$PDP_CTRL reloadpolicy

###############################################################

export LD_LIBRARY_PATH=/opt/glite/lib64
OPTS=" -d "
OPTS=" -v "
# OPTS=" "

$PEPCLI $OPTS -p https://`hostname`:8154/authz \
       -c $USERPROXY \
       --cert $USERCERT --key $USERKEY --keypasswd "test" \
       --capath /etc/grid-security/certificates/ \
       -r "resource_1" \
       -a "testwerfer" > /tmp/${script_name}.out
result=$?; # echo $result

echo "---------------------------------------"
cat /tmp/${script_name}.out
echo "---------------------------------------"
#
# looking for
#
# ERROR, no primary group found (the DN is not in the group mapfile)
# So in fact should look for "Deny"
# and processing error
# and "Failed to map"
# 
if [ $result -eq 0 ]
then
    grep -qi "deny" /tmp/${script_name}.out;
    if [ $? -ne 0 ]
    then
        echo "${script_name}: Did not find expected rule: $RULE."
        failed="yes"
    fi
    grep_term="Failed to map subject "
    grep "Failed to map subject " /tmp/${script_name}.out; result=$?
    if [ $result -ne 0  ]
    then
        echo "${script_name}: Did not find expected \"$grep_term\" " 
        failed="yes"
    fi
fi

exit 0;

#
# OK. Now we gotta test with a proxy!
#

$PEPCLI $OPTS -p https://`hostname`:8154/authz \
       -c /tmp/x509up_u0 \
       --capath /etc/grid-security/certificates/ \
       --key $USERKEY \
       --cert $USERCERT \
       -r "resource_1" \
       --keypasswd "test" \
       -a "testwerfer" > /tmp/${script_name}.out
result=$?; # echo $result

echo "---------------------------------------"
cat /tmp/${script_name}.out
echo "---------------------------------------"

#
# looking for
#
# uid: dteamXXX
# gid: dteam
# secondary gids: dteam
#
if [ $result -eq 0 ]
then
    grep -qi $RULE /tmp/${script_name}.out;
    if [ $? -ne 0 ]
    then
        echo "${script_name}: Did not find expected rule: $RULE."
        failed="yes"
    else
        WANTED_UID="dteam"
        grep_term="Username: "
        foo=`grep $grep_term /tmp/${script_name}.out`
        search_term=${foo#$grep_term};
        if [ "${search_term%%[0-9]*[0-9]}" != "$WANTED_UID" ]
        then
            echo "${script_name}: Did not find expected uid: ${WANTED_UID}."
            failed="yes"
        fi
        grep_term="Group: "
        foo=`grep $grep_term /tmp/${script_name}.out`
        search_term=${foo#$grep_term};
        if [ "${search_term}" != "dteam" ]
        then
            echo "${script_name}: Did not find expected group: ${DN_UID_GROUP}."
            failed="yes"
        fi
#
# Secondary groups (will be either dteam or $DN_UID_GROUP
#
        grep_term="Secondary "
        foo=`grep $grep_term /tmp/${script_name}.out`;
        search_term=${foo#"Secondary "}; # echo $search_term
        search_term=${search_term#"Groups: "}; # echo $search_term
        groups=( $search_term )
        i=0
        while [ ! -z ${groups[$i]} ]
        do
            if [ "${groups[$i]}" != "dteam" ]
            then 
                if [ "${groups[$i]}" != "$DN_UID_GROUP" ]
                then
                    echo "${script_name}: Secondary groups $search_term found."
                    echo "${script_name}: Expecting dteam and ${DN_UID_GROUP}."
                    failed="yes"
                fi
            fi
            let i=$i+1;
        done
    fi
fi

###############################################################
#
# clean up...
#
# Make sure to return the files
#
# Copy the files:
# /etc/grid-security/grid-mapfile
# /etc/grid-security/groupmapfile
# /etc/grid-security/voms-grid-mapfile

source_dir="/tmp/"
target_dir="/etc/grid-security"
target_file="grid-mapfile"
cp ${source_dir}/${target_file}.${script_name} ${target_dir}/${target_file}
target_file="voms-grid-mapfile"
cp ${source_dir}/${target_file}.${script_name} ${target_dir}/${target_file}
target_file="groupmapfile"
cp ${source_dir}/${target_file}.${script_name} ${target_dir}/${target_file}

cp ${pep_config_saved} ${pep_config}

clean_up=0
# clean_up=1

if [ $failed == "yes" ]; then
  echo "---${script_name}: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---${script_name}: TEST PASSED---"
  echo `date`
  exit 0
fi

exit 0