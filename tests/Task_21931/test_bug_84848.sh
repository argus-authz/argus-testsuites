#!/bin/sh

script_name=`basename $0`
passed="yes"

#########################################################
# Test if the Services are present on the system and setting some variables
# This is done for every test, even if the variables are not needed
if [ -z $PAP_HOME ]; then
if [ -d /usr/share/argus/pap ]
then
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
PAP_HOME=/usr/share/argus/pdp
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



echo `date`
echo "---Test: use VOMS Java API 2.0.6---"
#########################################################

export currentDir=`pwd`
export papHome=/usr/share/argus/pap/lib
export pdpHome=/usr/share/argus/pdp/lib
export pepdHome=/usr/share/argus/pepd/lib

echo "1) Test if the the links to the appropriate jars exists for the pap:"

for i in `cat list_pap_84848.txt`
do
	echo $i
	if test -L $papHome/$i && test -f $papHome/$1; then 
		passed="no"
		echo "$papHome/$i does not exists"
	else
		echo "this is a link and the target exists"
	fi
done
echo "-------------------------------"
echo ""
cd $currentDir

echo "2) Test if the the links to the appropriate jars exists for the pdp:"

for i in `cat list_pdp_84848.txt`
do 
        echo $i
        if test -L $pdpHome/$i && test -f $pdpHome/$1; then
                passed="no"
        else
                echo "this is a link and the target exists"
        fi
done
echo "-------------------------------"
echo ""
cd $currentDir

echo "3) Test if the the links to the appropriate jars exists for the pepd:"

for i in `cat list_pepd_84848.txt`
do 
        echo $i
        if test -L $pepdHome/$i && test -f $pepdHome/$1; then
                passed="no"
        else
                echo "this is a link and the target exists"
        fi
done
echo "-------------------------------"
echo ""
cd $currentDir

if [ $passed == "no" ]; then
echo "---Test: implement memory limit: TEST FAILED---"
echo `date`
exit 1
else
echo "---Test: use VOMS Java API 2.0.6: TEST PASSED---"
echo `date`
exit 0
fi

