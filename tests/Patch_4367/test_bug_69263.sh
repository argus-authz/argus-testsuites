#!/bin/sh

script_name=`basename $0`
failed="no"

####################################################
#adapt the script to be compatible with EMI and EGEE
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
if [ -f /etc/rc.d/init.d/pepd ]
then
PEP_CTRL=pepd;
fi
echo "PEP_CTRL set to: $PEP_CTRL"
#until here
####################################################

configfile="$PEP_HOME/conf/pepd.ini"

echo "Running: ${script_name}"
echo `date`

/etc/rc.d/init.d/$PEP_CTRL status > /dev/null
if [ $? -ne 0 ]; then
    echo "${script_name}: PEPd is not running. Good."
else
    echo "${script_name}: Stopping PEPd."
    /etc/rc.d/init.d/$PEP_CTRL stop > /dev/null
    sleep 5
fi

# Change the pips section to comment out...

grep pips $configfile
echo "changed to:"
sed -i 's/pips =/# pips =/g' $configfile
grep pips $configfile
# Now try to start pepd.

echo "${script_name}: Starting PEPd."
/etc/rc.d/init.d/$PEP_CTRL start > /dev/null; result=$?;
sleep 5
# echo $result
if [ $result -eq 0 ]
then
    echo "${script_name}: Stopping PEPd."
    /etc/rc.d/init.d/$PEP_CTRL stop > /dev/null
    sleep 5
else
    echo "${script_name}: PEPd failed to start."
    failed="yes"
fi

# Now restore to original

sed -i 's/# pips =/pips =/g' $configfile

# Now try to start pepd.

echo "${script_name}: Starting PEPd."
/etc/rc.d/init.d/$PEP_CTRL start > /dev/null; result=$?;
sleep 5
# echo $result

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

