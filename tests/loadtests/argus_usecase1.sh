#!/bin/sh


function usage() {
echo "Usage: $0 -n <#requests> -p <certsdir>"
echo "       $0 -d <end date > -p <certsdir> (The format must be YYYYMMDDhhmm, returned by date +%Y%m%d%H%M)"
}

if [ $# != 4 ]; then
  usage
  exit 1
fi

until [ -z "$1" ]
do
  case "$1" in
     -n)
         if [ -z "$2" ]; then
           usage
           exit 1
         else
           ITERATIONS=$2
           shift 2
         fi
     ;;
     -d)
         if [ -z "$2" ]; then
           usage
           exit 1
         else
           END_DATE=$2
           shift 2
         fi
     ;;
     -p)
         if [ -z "$2" ]; then
           usage
           exit 1
         else
           CERTSDIR=$2
           shift 2
         fi
     ;;

     *)
        usage
        exit 1
     ;;
  esac
done


rm -f out.txt res_*.txt res.txt

for user in {300..309}
do
  iterations[$user]=0
done

echo -n "Started on: "
date

if [ ! -z $END_DATE ]; then
  echo "The test will end on $END_DATE"
fi
if [ ! -z $ITERATIONS ]; then
  echo "The test will do $ITERATIONS iterations"
fi

#Execute operations
######################################################
if [ ! -z $END_DATE ]; then
  CURR_DATE=`date +%Y%m%d%H%M`
  i=1
  while [ $CURR_DATE -lt $END_DATE ]
  do
    index=$(($RANDOM % 10))
    let "iterations[index]=iterations[index]+1"
    cert=$CERTSDIR/test_user_30${index}_cert.pem
    curr_date=`date +%Y%m%d%H%M`
    echo -n "$curr_date " >> res_30${index}.txt 
    echo -n "$i " >> out.txt
    (/usr/bin/time --format=%e pepcli --pepd http://vtb-generic-98.cern.ch:8154/authz -c $cert --resourceid "resource_1" --actionid "submit-job" -t 60 -x; echo "exit code: $?") >>res_30${index}.txt 2>>out.txt
#    sleep $(($RANDOM % 5))
    CURR_DATE=`date +%Y%m%d%H%M`
    let "i +=1"
  done
  echo "$i iterations done"
fi

##############################
i=1
if [ ! -z $ITERATIONS ]; then
  while [ $i -le $ITERATIONS ]
  do
    echo -n "$i " >> out.txt
    index=$(($RANDOM % 10))
    let "iterations[index]=iterations[index]+1"
    curr_date=`date +%Y%m%d%H%M`
    echo -n "$curr_date " >> res_30${index}.txt 
    cert=$CERTSDIR/test_user_30${index}_cert.pem
    (/usr/bin/time --format=%e pepcli --pepd http://vtb-generic-98.cern.ch:8154/authz -c $cert --resourceid "resource_1" --actionid "submit-job" -t 60 -x; echo "exit code: $?") >>res_30${index}.txt 2>>out.txt
#    sleep $(($RANDOM % 5))
    let "i +=1"
  done
fi

echo -n "Ended on: "
date

echo "Checking results..."
####################################################
#Check results
for user in {0..9}
do
  mapped_user=`grep -m 1 dteam res_30${user}.txt | awk -F = '{print \$2}'`
  if [ "x$mapped_user" != "x" ]; then 
    echo -n "User 30$user should be mapped to $mapped_user: "
    good_mappings=`grep $mapped_user res_30${user}.txt | wc -l`
    if [ $good_mappings -eq ${iterations[$user]} ]; then
      echo "OK"
    else
      echo "Error. good_mappings=$good_mappings, iterations=${iterations[$user]}"
    fi
  else
   echo -n "User 30$user should be always banned: "
   denials=`grep Deny res_30${user}.txt | wc -l`
   if [ $denials -eq ${iterations[$user]} ]; then
      echo "OK"
    else
      echo "Error. denials=$denials, iterations=${iterations[$user]}"
    fi
  fi
done

