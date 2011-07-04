#!/bin/bash

PROXY=${X509_USER_PROXY:-/tmp/x509_up`id -u`}
CERT=$PROXY
KEY=$PROXY
VO=dteam
KEYPASSWD="test"
JAVACLI="../pep-java-cli/bin/pep-java-cli"

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
  echo "#pep-j certification test# $1"
}

usage() {
 echo
 echo "Usage:"
 echo "======"
 echo "pepj-test.sh -s <server>"
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
$JAVACLI -cadir /etc/grid-security/certificates/ -cert $CERT -key $KEY -keypasswd "test" -pepd https://$server:8154/authz -subject $PROXY -resourceid test -actionid test 2>&1 |grep Username >/dev/null

if [ ${PIPESTATUS[0]} -ne 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "Error getting a mapping with a basic test. Did you set up the server properly?"
 myexit 1
fi
myecho "Succesfully got mapping"

myecho "Testing basic policy with subject based allow clause"
$JAVACLI -cadir /etc/grid-security/certificates/ -cert $CERT -key $KEY -keypasswd "test" -pepd https://$server:8154/authz -subject $PROXY -resourceid test2 -actionid test2 2>&1 |grep Username >/dev/null

if [ ${PIPESTATUS[0]} -ne 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "Error getting a mapping with a subject based test."
 myexit 1
fi
myecho "Succesfully got mapping"

myecho "Testing basic policy with subject based deny clause"
$JAVACLI -cadir /etc/grid-security/certificates/ -cert $CERT -key $KEY -keypasswd "test" -pepd https://$server:8154/authz -subject $PROXY -resourceid test3 -actionid test3 2>&1 |grep  Deny >/dev/null

if [ ${PIPESTATUS[0]} -eq 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "No Deny clause for rule reported."
 myexit 1
fi
myecho "Did nor receive mapping, which is correct behaviour."

myecho "Testing nonexisting policy"
$JAVACLI -cadir /etc/grid-security/certificates/ -cert $CERT -key $KEY -keypasswd "test" -pepd https://$server:8154/authz -subject $PROXY -resourceid test4 -actionid test4 |grep NotApplicable >/dev/null

if [ ${PIPESTATUS[0]} -eq 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "Nonexisting policy not reported."
 myexit 1
fi
myecho "Did nor receive mapping, which is correct behaviour."

myecho "Testing against a fake host"
$JAVACLI -cadir /etc/grid-security/certificates/ -cert $CERT -key $KEY -keypasswd "test" -pepd https://fakehost.cern.ch:8154/authz -subject $PROXY -resourceid test -actionid test 2>&1 | grep "No PEP daemon(s) \[[^]]*\] was able to process the request" >/dev/null

if [ ${PIPESTATUS[0]} -eq 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "Fake host error not reported."
 myexit 1
fi
myecho "Reported error for nonexisting Host"

myecho "Testing without a certificate"
$JAVACLI -cadir /etc/grid-security/certificates/ -cert ~/.globus/nosuchcert.pem -key $KEY -keypasswd "test" -pepd https://$server:8154/authz -subject $PROXY -resourceid test -actionid test 2>&1 |grep "No such file" >/dev/null

if [ ${PIPESTATUS[0]} -eq 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "No error given on missing file"
 myexit 1
fi
myecho "Got error message for missing file"

myecho "Testing without a key"

$JAVACLI -cadir /etc/grid-security/certificates/ -cert $CERT -key ~/.globus/nosuchkey.pem -keypasswd "test" -pepd https://$server:8154/authz -subject $PROXY -resourceid test -actionid test |grep "No such file" >/dev/null

if [ ${PIPESTATUS[0]} -eq 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "No error given on missing file"
 myexit 1
fi

myecho "Got error message for missing file"

myecho "Testing without a proxy"
$JAVACLI -cadir /etc/grid-security/certificates/ -cert $CERT -key $KEY -keypasswd "test" -pepd https://$server:8154/authz -subject /tmp/nosuchx509up_u0 -resourceid test -actionid test 2>&1 |grep "No such file" >/dev/null

if [ ${PIPESTATUS[0]} -eq 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "No error given on missing file"
 myexit 1
fi

myecho "Got error message for missing file"

myecho "Retrieving short proxy, to test with an expried proxy"
echo "test" | voms-proxy-init -pwstdin -valid 0:1 -voms dteam >/dev/null 2>&1

sleep 180

myecho "Testing with an expired proxy"
$JAVACLI -cadir /etc/grid-security/certificates/ -cert $CERT -key $KEY -keypasswd "test" -pepd https://$server:8154/authz -subject $PROXY -resourceid test -actionid test 2>&1 |grep "certificate_unknown" >/dev/null

if [ ${PIPESTATUS[0]} -eq 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
 myecho "No error given when using expired proxy"
 myexit 1
fi
myecho "Got error message for expired proxy file"

myexit 0
