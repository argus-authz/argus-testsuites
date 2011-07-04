#!/bin/sh

# This one should test the add obligation functionality

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
## To here for EGEE/EMI compatible tests

echo "Running: ${script_name}"
echo `date`

/etc/rc.d/init.d/$PEP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
  echo "PEPd is not running. Starting one."
  /etc/rc.d/init.d/$PEP_CTRL start
  sleep 10
fi

/etc/rc.d/init.d/$PDP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
  echo "PDP is not running. Starting one."
  /etc/rc.d/init.d/$PDP_CTRL start
  sleep 10
fi

/etc/rc.d/init.d/$PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  /etc/rc.d/init.d/$PAP_CTRL start;
  sleep 10;
fi

# Remove all policies defined for the default pap
$PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $PAP_HOME/bin/pap-admin rap"
  exit 1
fi

# Get my cert DN for usage later
declare subj_string;
foo=`openssl x509 -in /etc/grid-security/hostcert.pem -subject -noout`;
subj_string=`echo $foo | sed 's/subject= //'`

RESOURCE="resource_1"
ACTION="test_werfer"
RULE="permit"
OBLIGATION="http://glite.org/xacml/obligation/local-environment-map"
# Now should add the obligation?

OPTS=" -v "
OPTS=" "

$PAP_HOME/bin/pap-admin $OPTS ap \
             --resource ${RESOURCE} \
             --action $ACTION \
             --obligation $OBLIGATION \
             ${RULE} subject="${subj_string}"

# $PAP_HOME/bin/pap-admin lp -sai

###############################################################

# Is the obligation there?

CMD="$PAP_HOME/bin/pap-admin lp -srai"; 
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

id=`$PAP_HOME/bin/pap-admin lp -srai | grep 'id=[^public]' | sed 's/id=//'`
CMD="$PAP_HOME/bin/pap-admin ro $id $OBLIGATION";
$CMD

# Is the obligation there? It should not be
# Below should see return codes <>0, <>0, 0

CMD="$PAP_HOME/bin/pap-admin lp -sai"; 
$CMD > ${script_name}.out
grep $OBLIGATION  ${script_name}.out;result=$?
if [ $result -eq 0 ]
then
    echo "${script_name}: Obligation not removed."
    failed="yes"
fi

CMD="$PAP_HOME/bin/pap-admin ao $id $OBLIGATION"
$CMD

CMD="$PAP_HOME/bin/pap-admin lp -sai";
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

