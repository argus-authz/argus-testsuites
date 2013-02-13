#!/bin/bash

script_name=`basename $0`
failed="no"
policyfile=policyfile.txt

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

echo "Running: ${script_name}"
echo `date`

# Get my cert DN for usage later
declare subj_string;
foo=`openssl x509 -in /etc/grid-security/hostcert.pem -subject -noout`;
IFS=" "
subj_string=( $foo )


# Now should add the obligation?

$PAP_ADMIN ap --resource resource_1 \
             --action testwerfer \
             --obligation \
http://glite.org/xacml/obligation/local-environment-map permit subject="${subj_string[1]}"

###############################################################

$PAP_ADMIN lp -srai
sleep 5
$T_PDP_CTRL reloadpolicy
sleep 5
$T_PEP_CTRL clearcache
sleep 5

###############################################################

$PEPCLI -p https://`hostname`:8154/authz \
       -c /etc/grid-security/hostcert.pem \
       --capath /etc/grid-security/certificates/ \
       --key /etc/grid-security/hostkey.pem \
       --cert /etc/grid-security/hostcert.pem \
       -r "resource_1" \
       -a "testwerfer" \
       -f "/dteam" > $LOGSLOCATION/${script_name}.out
result=$?

if [ $result -eq 0 ]
then

    echo "$LOGSLOCATION/${script_name}.out"
    cat $LOGSLOCATION/${script_name}.out

    grep -q resource_1 $LOGSLOCATION/${script_name}.out;
    if [ $? -ne 0 ]
    then
        echo "${script_name}: Did not find expected resource: $RESOURCE"
        failed="yes"
    fi
    RULE=permit
    grep -qi $RULE $LOGSLOCATION/${script_name}.out;
    if [ $? -ne 0 ]
    then
	echo "${script_name}: Did not find expected rule: $RULE"
	failed="yes"
    fi

    declare groups;

    foo=`grep Username: $LOGSLOCATION/${script_name}.out`
    IFS=" "
    groups=( $foo )
    if [ ! -z ${groups[1]} ]
    then
        sleep 0;
    else
	echo "${script_name}: No user account mapped."
        failed="yes"
    fi
    foo=`grep Group: $LOGSLOCATION/${script_name}.out`
    IFS=" "
    groups=( $foo )
    if [ ! -z ${groups[1]} ]
    then
        sleep 0;
    else
        echo "${script_name}: No user group mapped."
        failed="yes"
    fi
    foo=`grep "Secondary Groups:" $LOGSLOCATION/${script_name}.out`
    IFS=" "
    groups=( $foo )
    if [ ! -z ${groups[1]} ]
    then
        sleep 0;
    else
        echo "${script_name}: No user secondary group mapped."
        failed="yes"
    fi
fi

###############################################################

if [ $failed == "yes" ]; then
  echo "---${script_name}: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---${script_name}: TEST PASSED---"
  echo `date`
  exit 0
fi

