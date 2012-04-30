#!/bin/bash

script_name=`basename $0`
failed="no"
policyfile=policyfile.txt

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

echo "Running: ${script_name}"
echo `date`

$T_PEP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
  echo "PEPd is not running. Starting one."
  $T_PEP_CTRL start
  sleep 10
fi

$T_PDP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
  echo "PDP is not running. Starting one."
  $T_PDP_CTRL start
  sleep 10
fi

$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  $T_PAP_CTRL start;
  sleep 10;
fi

# Remove all policies defined for the default pap
$PAP_ADMIN rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_ADMIN rap"
  exit 1
fi

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


# Get my cert DN for usage later
foo=`openssl x509 -in $USERCERT -subject -noout`
obligation_dn=`echo $foo | sed 's/subject= //'`
echo " subject string = $obligation_dn"

RESOURCE="resource_1"
ACTION="test_werfer"
RULE="permit"
OBLIGATION="http://glite.org/xacml/obligation/local-environment-map"
# Now should add the obligation?

OPTS=" -v "
OPTS=" "

$PAP_ADMIN $OPTS ap \
             --resource ${RESOURCE} \
             --action $ACTION \
             --obligation $OBLIGATION \
             ${RULE} subject="$obligation_dn"

#$PAP_ADMIN lp -srai

###############################################################

# Is the obligation there?

CMD="$PAP_ADMIN lp -srai"; 
$CMD > ${script_name}.out
grep -q 'obligation' ${script_name}.out;result=$?
if [ $result -ne 0 ]
then
    echo "${script_name}: No obligation found."
    failed="yes"
fi
grep -q $OBLIGATION  ${script_name}.out;result=$?
if [ $result -ne 0 ]
then
    echo "${script_name}: No $OBLIGATION found."
    failed="yes"
fi

###############################################################

# Now get the ID

id=`$PAP_ADMIN lp -srai | grep 'id=[^public]' | sed 's/id=//'`
CMD="$PAP_ADMIN ro $id $OBLIGATION";
echo $CMD
$CMD

# Is the obligation there? It should not be
# Below should see return codes <>0, <>0, 0

CMD="$PAP_ADMIN lp -srai"; 
$CMD > ${script_name}.out
grep $OBLIGATION  ${script_name}.out;result=$?
if [ $result -eq 0 ]
then
    echo "${script_name}: Obligation not removed."
    failed="yes"
fi

CMD="$PAP_ADMIN ao $id $OBLIGATION"
$CMD

CMD="$PAP_ADMIN lp -sai";
$CMD > ${script_name}.out
grep -q 'obligation' ${script_name}.out;result=$?
if [ $result -ne 0 ]
then
    echo "${script_name}: No obligation found."
    failed="yes"
fi
grep -q $OBLIGATION  ${script_name}.out;result=$?
if [ $result -ne 0 ]
then
    echo "${script_name}: No $OBLIGATION found."
    failed="yes"
fi

###############################################################
#clean up

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

