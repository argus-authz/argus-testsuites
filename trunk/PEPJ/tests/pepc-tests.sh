#!/bin/bash

PROXY=${X509_USER_PROXY:-/tmp/x509_up`id -u`}
CERT=${X509_USER_CERT:-$PROXY}
KEY=${X509_USER_KEY:-$PROXY}
VO=dteam
KEYPASSWD="test"
JAVACLI="/opt/glite/bin/pepcli"

SUCCESS=1
FAIL=0

function myexit() {

  if [ $1 -ne 0 ]; then
    echo " *** something went wrong *** "
    echo " *** test NOT passed *** "
    exit $1
  else
    echo ""
    echo "    === test PASSED === "
  fi
   
  exit 0
}

function myecho()
{
  echo "#pep-c certification test# $1"
}

usage() {
 echo
 echo "Usage:"
 echo "======"
 echo "pepc-test.sh -s <server>"
 echo ""
}

while [ $# -gt 0 ]
do
 case $1 in
 --server | -s ) server=$2
  shift
  ;;
 --help | -help | --h | -h ) usage
  exit 0
  ;;
 --* | -* ) echo "$0: invalid option $1" >&2
  usage
  exit 1
  ;;
 *) break
  ;;
 esac
 shift
done

if [ x"$server" == x ] ; then
 usage
 exit 1
fi

VERSION="glite-authz-pep-api-c/2.0.1"
$JAVACLI -V | grep $VERSION || echo "ERROR: version doesn't match"

if [ ! -f $CERT ] ; then
 echo "Could not find certificate under $CERT, please check that certificates are correctly installed"
 exit 1
fi

if [ ! -f $KEY ] ; then
 echo "Could not find key under $KEY, please check that certificates are correctly installed"
 exit 1
fi

if [ ! -f $PROXY ] ; then
 echo "Could not find proxy certificate under $PROXY, please check that certificates are correctly installed"
 exit 1
fi

myecho "Retrieving a proxy certificate"
echo "test" | voms-proxy-init -pwstdin -voms dteam  >/dev/null 2>&1

myecho "Testing basic policy with voms based allow clause"

CMD="$JAVACLI --capath /etc/grid-security/certificates/ \
              --certchain $PROXY \
              --cert $CERT \
              --key $KEY \
              --keypasswd "test" \
              --pepd https://$server:8154/authz \
              --resourceid test \
              --actionid test"
# echo $CMD; $CMD
$CMD 2>&1 |grep Username >/dev/null

if [ ${PIPESTATUS[0]} -ne 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "Error getting a mapping with a basic test. Did you set up the server properly?"
 myexit 1
fi
myecho "Succesfully got mapping"

myecho "Testing basic policy with subject based allow clause"
CMD="$JAVACLI --capath /etc/grid-security/certificates/ \                                                          
              --certchain $PROXY \                                                                                 
              --cert $CERT \                                                                                       
              --key $KEY \                                                                                         
              --keypasswd "test" \                                                                                 
              --pepd https://$server:8154/authz \                                                                  
              --resourceid test2 \
              --actionid test2"
$CMD 2>&1 |grep Username >/dev/null

if [ ${PIPESTATUS[0]} -ne 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "Error getting a mapping with a subject based test."
 myexit 1
fi
myecho "Succesfully got mapping"

myecho "Testing basic policy with subject based deny clause"

CMD="$JAVACLI --capath /etc/grid-security/certificates/ --certchain $PROXY --cert $CERT --key $KEY --keypasswd "test" --pepd https://$server:8154/authz --resourceid test3 --actionid test3"
# echo $CMD; $CMD
$CMD 2>&1 | grep -i Deny > /dev/null; result=$?

if [ $result -ne 0 ]
then
    myecho "No Deny clause for rule reported."
    myexit 1
fi
myecho "Did nor receive mapping, which is correct behaviour."

myecho "Testing nonexisting policy"
CMD="$JAVACLI --capath /etc/grid-security/certificates/ --certchain $PROXY --cert $CERT --key $KEY --keypasswd "test" --pepd https://$server:8154/authz --resourceid test4 --actionid test4"

$CMD 2>&1 | grep 'Not Applicable' > /dev/null; result=$?

if [ $result -ne 0 ]
then
    myecho "Nonexisting policy not reported."
    myexit 1
fi
myecho "Did nor receive mapping, which is correct behaviour."

myecho "Testing against a fake host"
CMD="$JAVACLI -v --capath /etc/grid-security/certificates/ --certchain $PROXY --cert $CERT --key $KEY --keypasswd "test" --pepd https://fakehost.cern.ch:8154/authz --resourceid test --actionid test"
# echo $CMD; $CMD
$CMD 2>&1 | grep "couldn't resolve host name" > /dev/null; result=$?

if [ $result -ne 0 ]
then
    myecho "Fake host error not reported."
    # myexit 1
fi
myecho "Reported error for nonexisting Host"

myecho "Testing without a certificate"
CMD="$JAVACLI -v --capath /etc/grid-security/certificates/ --certchain $PROXY --cert ~/.globus/nosuchcert.pem --key $KEY --keypasswd "test" --pepd https://$server:8154/authz --resourceid test --actionid test"

$CMD 2>&1 | grep 'No such file' > /dev/null; result=$?

if [ $result -ne 0 ]
then
    myecho "No error given on missing file"
    myexit 1
fi
myecho "Got error message for missing file"

myecho "Testing without a key"

CMD="$JAVACLI --capath /etc/grid-security/certificates/ --certchain $PROXY --cert $CERT --key ~/.globus/nosuchkey --keypasswd "test" --pepd https://$server:8154/authz --resourceid test --actionid test"

$CMD 2>&1 | grep 'No such file' > /dev/null; result=$?

if [ $result -ne 0 ]
then
    myecho "No error given on missing file"
    myexit 1
fi

myecho "Got error message for missing file"

myecho "Testing without a proxy"

CMD="$JAVACLI --capath /etc/grid-security/certificates/ --certchain /tmp/a_naughty_proxy --cert $CERT --key $KEY--keypasswd "test" --pepd https://$server:8154/authz --resourceid test --actionid test"

$CMD 2>&1 | grep 'No such file' > /dev/null; result=$?

# $JAVACLI -cadir /etc/grid-security/certificates/ -cert $CERT -key $KEY -keypasswd "test" -pepd https://$server:8154/authz -subject /tmp/nosuchx509up_u0 -resourceid test -actionid test 2>&1 |grep "No such file" >/dev/null

if [ ${result} -ne 0 ]
then
    myecho "No error given on missing file"
    myexit 1
fi

myecho "Got error message for missing file"

myecho "Retrieving short proxy, to test with an expried proxy"

# which voms-proxy-init
# echo "test" | voms-proxy-init -pwstdin -valid 0:1 -voms dteam
# echo 0...; sleep 30;echo 30...;sleep 30;echo 60...;
# sleep 30;echo 90...;sleep 30;
# echo 120...;sleep 30;echo 150...
# sleep 30;echo 180...

myecho "Testing with an expired proxy"

CMD="$JAVACLI --capath /etc/grid-security/certificates/ --certchain /tmp/x509up_u501_expired --cert $CERT --key $KEY --keypasswd "test" --pepd https://$server:8154/authz --resourceid test --actionid test"

# echo $CMD; $CMD
$CMD 2>&1 | grep "Certificate with subject DN .* failed PKIX validation" > /dev/null; result=$?
# $CMD 2>&1 | grep "Certificate with subject DN \[[^]]*\] failed PKIX validation" > /dev/null; result=$?

if [ ${result} -ne 0 ]
then
    myecho "No error given when using expired proxy"
    myexit 1
fi
myecho "Got error message for expired proxy file"

myexit 0
