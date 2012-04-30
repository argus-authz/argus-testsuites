#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Set up the environment for the use of pepcli
source $FRAMEWORK/pepcli-env.sh

export LD_LIBRARY_PATH=/opt/glite/lib64
OPTS=" -d "
OPTS=" -v "
OPTS=" "

$PEPCLI $OPTS -p https://`hostname`:8154/authz \
       -c $USERCERT \
       --capath /etc/grid-security/certificates/ \
       --key $USERKEY \
       --cert $USERCERT \
       -r "resource_1" \
       --keypasswd $USERPWD \
       -a "testwerfer" > /tmp/${script_name}.out
result=$?; # echo $result

echo "---------------------------------------"
cat /tmp/${script_name}.out
echo "---------------------------------------"
#
# looking for
# Username: glite
# Group: testing
# Secondary Groups: testing
#
if [ $result -eq 0 ]
then
    grep -qi $RULE /tmp/${script_name}.out;
    if [ $? -ne 0 ]
    then
        echo "${script_name}: Did not find expected rule: $RULE."
        failed="yes"
    else
        grep_term="Username: "
        foo=`grep $grep_term /tmp/${script_name}.out`
        search_term=${foo#$grep_term};
        if [ "${search_term}" != "${DN_UID}" ]
        then
            echo "${script_name}: Did not find expected uid: ${DN_UID}."
            failed="yes"
        fi
        grep_term="Group: "
        foo=`grep $grep_term /tmp/${script_name}.out`
        search_term=${foo#$grep_term};
        if [ "${search_term}" != "${DN_UID_GROUP}" ]
        then
            echo "${script_name}: Did not find expected group: ${DN_UID_GROUP}."
            failed="yes"
        fi
#
# Secondary groups (will be $DN_UID_GROUP)
#
        grep_term="Secondary "
        foo=`grep $grep_term /tmp/${script_name}.out`;
        search_term=${foo#"Secondary "}; # echo $search_term
        search_term=${search_term#"Groups: "}; # echo $search_term
        groups=( $search_term )
        i=0
        while [ ! -z ${groups[$i]} ]
        do
                if [ "${groups[$i]}" != "$DN_UID_GROUP" ]
                then
                    echo "${script_name}: Secondary groups $search_term found."
                    echo "${script_name}: Expecting ${DN_UID_GROUP}."
                    failed="yes"
                fi
            let i=$i+1;
        done
    fi
fi

#
# OK. Now we gotta test with a proxy!
#

$PEPCLI $OPTS -p https://`hostname`:8154/authz \
       -c /tmp/x509up_u0 \
       --capath /etc/grid-security/certificates/ \
       --key $USERKEY \
       --cert $USERCERT \
       -r "resource_1" \
       --keypasswd $USERPWD \
       -a "testwerfer" > /tmp/${script_name}.out
result=$?; # echo $result

echo "---------------------------------------"
cat /tmp/${script_name}.out
echo "---------------------------------------"

#
# looking for
# Username: dteamXXX
# Group: testing
# Secondary Groups: testing dteam
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
        if [ "${search_term}" != "${DN_UID_GROUP}" ]
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

$SCRIPTBACKUPLOCATION/$T_PEP_INI $T_PEP_CONF/$T_PEP_INI

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