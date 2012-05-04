#!/bin/bash

script_name=`basename $0`
passed="yes"

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

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

