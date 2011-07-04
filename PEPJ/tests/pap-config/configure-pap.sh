#!/bin/bash

PAPBIN="/opt/argus/pap/bin/pap-admin"
PDPRELOAD="/etc/init.d/pdp reloadpolicy" 
PEPCLEAR="/etc/init.d/pepd clearcache"


usage() {
 echo
 echo "Usage:"
 echo "======"
 echo "configure-pap.sh "
 echo "Adds the required rules for certification to the Argus server."
 echo ""
}

while [ $# -gt 0 ]
do
 case $1 in 
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


confdir=`dirname $0`

echo "Adding new policies"
$PAPBIN apf $confdir/policy1
$PAPBIN apf $confdir/policy2
$PAPBIN apf $confdir/policy3

echo "Reloading policy data"
$PDPRELOAD
$PEPCLEAR

echo "Ready, you can now run certification test"
