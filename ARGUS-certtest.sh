#!/bin/sh
##############################################################################
# Copyright (c) Members of the EGEE Collaboration. 2009.
# See http://www.eu-egee.org/partners/ for details on the copyright
# holders.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##############################################################################
#
# AUTHORS: Gianni Pucciani, CERN
#
##############################################################################

showUsage ()
{
 echo "                                           "
 echo "Usage:  ARGUS-certtest.sh [-f <conf.file>]    "
 echo "  <conf.file> Configuration file, default is ARGUS-certconfig"
 echo "                                           "
}

exitFailure ()
{
echo "------------------------------------------------"
echo "END `date`"
echo "-TEST FAILED-"
exit -1
}

#######################
#Parsing the arguments#
#######################
if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] || [ $# -gt 2 ]; then
  showUsage
  exit 2
fi

if [ "$1" = "-f" ]; then
  conffile=$2
else
  conffile="./ARGUS-certconfig"
fi

###################################
# Check for environment variables #
###################################

if [ -e $conffile ]; then
  echo "Using $conffile"
  source $conffile
else
  echo "Config File $conffile does not exist"
  exitFailure
fi

if [ -z "$PAP_HOME" ]; then
  echo "You need to set PAP_HOME in order to run this script"
  exitFailure
fi

#########
# START #
#########

echo "START `date` "
echo "------------------------------------------------"

####################################
# Create a directory for log files #
####################################

id=`date +%y%m%d%H%M%S`
if [ -z "$LOGSLOCATION" ]; then
  cp=`pwd`
  loglocation=$cp/logs_$id
  mkdir -p $loglocation
else
  loglocation=$LOGSLOCATION/logs_$id
  mkdir -p $loglocation
fi

if [ ! -d $loglocation ];then
  echo   "Error while creating log directory $loglocation"
  exitFailure
else
  echo "Log files will be stored in $loglocation"
fi

########################
# Launch all the tests #
########################

declare -a tests_failed
failed=no

#################
# PAP-CLI tests #
#################

if [ "x${PAP_CLI}" = "xyes" ]; then

  echo "*Running PAP-CLI tests"
  pushd ./tests/PAP-CLI >> /dev/null
  declare -a tests_list
#  tests_list=("${tests_list[@]}" "test-PAP-FUNC-1.sh")
  tests_list=("${tests_list[@]}" "test-PAP-FUNC-2.sh")
  tests_list=("${tests_list[@]}" "test-list-policies.sh")
  tests_list=("${tests_list[@]}" "test-ban-unban.sh")
  tests_list=("${tests_list[@]}" "test-ban-unban-fqan.sh")
  tests_list=("${tests_list[@]}" "test-remove-all-policies.sh")
  tests_list=("${tests_list[@]}" "test-remove-policies.sh")
  tests_list=("${tests_list[@]}" "test-policy-from-file.sh")
  tests_list=("${tests_list[@]}" "test-upp-from-file.sh")
 
#  tests_list=( test-policy-from-file.sh test-remove-all-policies.sh test-remove-policies.sh test-PAP-FUNC-1.sh test-list-policies.sh test-upp-from-file.sh )

  for item in ${tests_list[*]}
  do
    rm -rf ${item}_result.txt
    ./$item  > $loglocation/${item}_result.txt 2>&1
    if [ $? -ne 0 ]; then
      echo "$item FAILED"
      failed=yes
      tests_failed=( "${tests_failed[@]}" "$item" )
    else
      echo "$item PASSED" 
    fi
  done
  popd >> /dev/null
else
  echo "*PAP-CLI tests skipped"
fi

########################
# PAP_management tests #
########################
echo "*Running PAP-management tests"
unset tests_list

if [ "x${PAP_management}" = "xyes" ]; then
  pushd ./tests/PAP-management >> /dev/null
  declare -a tests_list
  tests_list=("${tests_list[@]}" "add-remove-localpap.sh")
  tests_list=("${tests_list[@]}" "en-disable-pap.sh")
  tests_list=("${tests_list[@]}" "pap-ping.sh")
  tests_list=("${tests_list[@]}" "refresh-cache.sh")
  tests_list=("${tests_list[@]}" "set-get-pap-orders.sh")
  tests_list=("${tests_list[@]}" "set-get-poll-interval.sh")
  tests_list=("${tests_list[@]}" "test-authz.sh")
  tests_list=("${tests_list[@]}" "update-pap.sh")
 
#  tests_list=( test-policy-from-file.sh test-remove-all-policies.sh test-remove-policies.sh test-PAP-FUNC-1.sh test-list-policies.sh test-upp-from-file.sh )

  for item in ${tests_list[*]}
  do
    rm -rf ${item}_result.txt
    ./$item  > $loglocation/${item}_result.txt 2>&1
    if [ $? -ne 0 ]; then
      echo "$item FAILED"
      failed=yes
      tests_failed=( "${tests_failed[@]}" "$item" )
    else
      echo "$item PASSED" 
    fi
  done
  popd >> /dev/null
else
  echo "*PAP_management tests skipped"
fi

#############
# PDP tests #
#############
echo "*Running PDP tests"
unset tests_list

if [ "x${PDP}" = "xyes" ]; then
  pushd ./tests/PDP >> /dev/null
  declare -a tests_list
  tests_list=("${tests_list[@]}" "test-configuration.sh")
 
#  tests_list=( test-policy-from-file.sh test-remove-all-policies.sh test-remove-policies.sh test-PAP-FUNC-1.sh test-list-policies.sh test-upp-from-file.sh )

  for item in ${tests_list[*]}
  do
    rm -rf ${item}_result.txt
    ./$item  > $loglocation/${item}_result.txt 2>&1
    if [ $? -ne 0 ]; then
      echo "$item FAILED"
      failed=yes
      tests_failed=( "${tests_failed[@]}" "$item" )
    else
      echo "$item PASSED" 
    fi
  done
  popd >> /dev/null
else
  echo "*PDP tests skipped"
fi

#############
# PEP tests #
#############
echo "*Running PEP tests"
unset tests_list

if [ "x${PEP}" = "xyes" ]; then
  pushd ./tests/PEP >> /dev/null
  declare -a tests_list
  tests_list=("${tests_list[@]}" "test-configuration.sh")

  for item in ${tests_list[*]}
  do
    rm -rf ${item}_result.txt
    ./$item  > $loglocation/${item}_result.txt 2>&1
    if [ $? -ne 0 ]; then
      echo "$item FAILED"
      failed=yes
      tests_failed=( "${tests_failed[@]}" "$item" )
    else
      echo "$item PASSED" 
    fi
  done
  popd >> /dev/null
else
  echo "*PEP tests skipped"
fi

####################                                                                                                   
# Patch 4367 tests #                                                                                                     
####################                                                                                             

SUITE="Patch_4367"        
echo "*Running $SUITE tests"
unset tests_list

if [ "x${Patch4367}" = "xyes" ]; then
  pushd ./tests/$SUITE >> /dev/null

  declare -a tests_list
  tests_list=`ls -1 *.sh`

  for item in ${tests_list[*]}
  do
    rm -rf ${item}_result.txt
    ./$item  > $loglocation/${item}_result.txt 2>&1
    if [ $? -ne 0 ]; then
      echo "$item FAILED"
      failed=yes
      tests_failed=( "${tests_failed[@]}" "$item" )
    else
      echo "$item PASSED"
    fi
  done
  popd >> /dev/null
else
  echo "* $SUITE tests skipped"
fi

#########################
# Analyse tests outcome #
#########################

if [ $failed = "yes" ]; then

  echo "TEST_FAILED"
  echo "The following tests failed:"
  for item in ${tests_failed[*]}
  do
    echo "$item: results in $loglocation/${item}_result.txt"
  done
  exit 1
else
    echo "TEST_PASSED"
  exit 0
fi

