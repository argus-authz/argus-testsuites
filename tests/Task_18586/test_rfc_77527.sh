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
echo "---Test: oneline DN format---"
#########################################################

echo "1) a JUnit exists for that specific RFC, its output is:"
echo "---"
echo "Running org.glite.authz.pep.pip.provider.OpenSSLSubjectPIPTest
OpenSSL subject attribute IDs to convert: [http://glite.org/xacml/attribute/subject-issuer, urn:oasis:names:tc:xacml:1.0:subject:subject-id]
OpenSSL subject attribute datatypes to convert: [http://www.w3.org/2001/XMLSchema#string]
before: Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: http://glite.org/xacml/attribute/subject-issuer, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[/C=ch/O=SWITCH/OU=Grid/CN=Grid Root CA, /C=ch/O=SWITCH/OU=Grid/CN=Grid Issuing CA]}, Attribute{ id: urn:oasis:names:tc:xacml:1.0:subject:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[/C=ch/O=SWITCH/CN=Valery Tschopp]}]}], resources:[Resource{ content: null, attributes:[Attribute{ id: urn:oasis:names:tc:xacml:1.0:resource:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[switch]}]}], action: Action{ attributes:[Attribute{ id: urn:oasis:names:tc:xacml:1.0:action:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[switch]}]}, environment: null}
after: Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: http://glite.org/xacml/attribute/subject-issuer, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[/C=ch/O=SWITCH/OU=Grid/CN=Grid Root CA, /C=ch/O=SWITCH/OU=Grid/CN=Grid Issuing CA]}, Attribute{ id: urn:oasis:names:tc:xacml:1.0:subject:subject-id, dataType: urn:oasis:names:tc:xacml:1.0:data-type:x500Name, issuer: null, values:[CN=Valery Tschopp,O=SWITCH,C=ch]}, Attribute{ id: http://glite.org/xacml/attribute/subject-issuer, dataType: urn:oasis:names:tc:xacml:1.0:data-type:x500Name, issuer: null, values:[CN=Grid Issuing CA,OU=Grid,O=SWITCH,C=ch, CN=Grid Root CA,OU=Grid,O=SWITCH,C=ch]}, Attribute{ id: urn:oasis:names:tc:xacml:1.0:subject:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[/C=ch/O=SWITCH/CN=Valery Tschopp]}]}], resources:[Resource{ content: null, attributes:[Attribute{ id: urn:oasis:names:tc:xacml:1.0:resource:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[switch]}]}], action: Action{ attributes:[Attribute{ id: urn:oasis:names:tc:xacml:1.0:action:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[switch]}]}, environment: null}
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.008 sec"
echo "---"
echo "OK"
echo "-------------------------------"



if [ $passed == "no" ]; then
echo "---Test: oneline DN format: TEST FAILED---"
echo `date`
exit 1
else
echo "---Test: oneline DN format: TEST PASSED---"
echo `date`
exit 0
fi
