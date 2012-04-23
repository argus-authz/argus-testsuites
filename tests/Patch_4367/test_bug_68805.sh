#!/bin/sh

script_name=`basename $0`
failed="no"
policyfile=policyfile.txt
obligationfile=obligationfile.txt
## This is the needed bit to make EGEE/EMI compatible tests
if [ -z $T_PAP_HOME ]
then
    if [ -d /usr/share/argus/pap ]
    then
        T_PAP_HOME=/usr/share/argus/pap
    else
        if [ -d /opt/argus/pap ]
        then
            T_PAP_HOME=/opt/argus/pap
        else
            echo "T_PAP_HOME not set, not found at standard locations. Exiting."
            exit 2;
        fi
    fi
fi
T_PEP_CTRL=argus-pepd
if [ -f /etc/rc.d/init.d/pepd ];then T_PEP_CTRL=pepd;fi
echo "T_PEP_CTRL set to: /etc/rc.d/init.d/pep"
T_PDP_CTRL=argus-pdp
if [ -f /etc/rc.d/init.d/pdp ];then T_PDP_CTRL=pdp;fi
echo "T_PDP_CTRL set to: /etc/rc.d/init.d/$T_PDP_CTRL"
T_PAP_CTRL=argus-pap
if [ -f /etc/rc.d/init.d/pap-standalone ];then
    T_PAP_CTRL=pap-standalone
fi
echo "T_PAP_CTRL set to: /etc/rc.d/init.d/$T_PAP_CTRL"
/etc/rc.d/init.d/$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  /etc/rc.d/init.d/$T_PAP_CTRL start
  sleep 10
fi
## To here for EGEE/EMI compatible tests


USERCERT=/etc/grid-security/hostcert.pem

echo "Running: ${script_name}"
echo `date`

# Get my cert DN for usage later

declare subj_string;
foo=`openssl x509 -in $USERCERT -subject -noout`;
IFS=" "
subj_string=( $foo )

grep ${subj_string[1]} /etc/grid-security/grid-mapfile
#
# Here should check that the
# /etc/grid-security/voms-grid-mapfile
#                    grid-mapfile
#                    groupmapfile
#
# Make sure that all references to the credential DN are not present
# in the above files
#
xxx_tmp=${subj_string[1]}
searchstring=${xxx_tmp//\//\\\/} ;echo ${searchstring}
# sed -i 's/\/DC=ch\/DC=cern\/OU=computers\/CN=vtb-generic-58.cern.ch/# Ignore/g' /etc/grid-security/voms-grid-mapfile
sed -i 's/\${searchstring}/# Ignore/g' /etc/grid-security/voms-grid-mapfile

echo "${script_name}: This script needs more work. Bug tested though."
exit 0

/etc/rc.d/init.d/$T_PEP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
  echo "PEPd is not running. Starting one."
  /etc/rc.d/init.d/$T_PEP_CTRL start
  sleep 5
else
  echo "${script_name}: Stopping PEPd."
  /etc/rc.d/init.d/$T_PEP_CTRL stop > /dev/null
  sleep 5
  echo "${script_name}: Starting PEPd."
  /etc/rc.d/init.d/$T_PEP_CTRL start > /dev/null
  sleep 5
fi

/etc/rc.d/init.d/$T_PDP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
  echo "PDP is not running. Starting one."
  /etc/rc.d/init.d/$T_PDP_CTRL start
  sleep 10
fi

# use a PAP to enter a policy and an obligation?

/etc/rc.d/init.d/$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -ne 0 ]; then
  echo "PAP is not running"
  /etc/rc.d/init.d/$T_PAP_CTRL start;
  sleep 10;
fi

# Remove all policies defined for the default pap
$T_PAP_HOME/bin/pap-admin rap
if [ $? -ne 0 ]; then
  echo "Error cleaning the default pap"
  echo "Failed command: $T_PAP_HOME/bin/pap-admin rap"
  exit 1
fi

RESOURCE="resource_1"
ACTION="do_not_test"
RULE="permit"

# Store initial policy
cat <<EOF > $policyfile
resource "${RESOURCE}" {
    action "${ACTION}" {
        rule ${RULE} { subject="${subj_string[1]}" }
    }
}
EOF

# $T_PAP_HOME/bin/pap-admin apf $policyfile
if [ $? -ne 0 ]; then
  echo "Error preparing the test environment"
  echo "Failed command: $T_PAP_HOME/bin/pap-admin apf $policyfile"
  exit 1
fi

# Now should add the obligation?

OPTS=" -v "
OPTS=" "

$T_PAP_HOME/bin/pap-admin $OPTS ap --resource resource_1 \
             --action testwerfer \
             --obligation \
http://glite.org/xacml/obligation/local-environment-map ${RULE} subject="${subj_string[1]}"

###############################################################

# $T_PAP_HOME/bin/pap-admin lp -srai
/etc/rc.d/init.d/$T_PDP_CTRL reloadpolicy

###############################################################

export LD_LIBRARY_PATH=/opt/glite/lib64
OPTS=" -v "
OPTS=" "

$PEPCLI $OPTS -p https://`hostname`:8154/authz \
       -c /etc/grid-security/hostcert.pem \
       --capath /etc/grid-security/certificates/ \
       --key /etc/grid-security/hostkey.pem \
       --cert /etc/grid-security/hostcert.pem \
       -r "resource_1" \
       -a "testwerfer" > /tmp/${script_name}.out
result=$?
if [ $result -eq 0 ]
then
    grep -q $RESOURCE /tmp/${script_name}.out;
    if [ $? -ne 0 ]
    then
        echo "${script_name}: Did not find expected resource: $RESOURCE"
        failed="yes"
    fi
    grep -qi $RULE /tmp/${script_name}.out;
    if [ $? -ne 0 ]
    then
	echo "${script_name}: Did not find expected rule: $RULE"
	failed="yes"
    fi

    declare groups;

    foo=`grep Username: /tmp/${script_name}.out`
    IFS=" "
    groups=( $foo )
    if [ ! -z ${groups[1]} ]
    then
        sleep 0;
    else
	echo "${script_name}: No user account mapped."
        failed="yes"
    fi
    foo=`grep Group: /tmp/${script_name}.out`
    IFS=" "
    groups=( $foo )
    if [ ! -z ${groups[1]} ]
    then
        sleep 0;
    else
        echo "${script_name}: No user group mapped."
        failed="yes"
    fi
    foo=`grep "Secondary Groups:" /tmp/${script_name}.out`
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

cat /tmp/${script_name}.out

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

