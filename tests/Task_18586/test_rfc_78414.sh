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
echo "---Test: PIP to validate request---"
#########################################################

echo "1) a JUnit exists for that specific RFC, its output is:"
echo "---"
echo "Running org.glite.authz.pep.pip.provider.RequestValidatorPIPTest
Request{ subjects:[], resources:[Resource{ content: null, attributes:[Attribute{ id: x-urn:junit:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[titi]}]}], action: Action{ attributes:[Attribute{ id: x-urn:junit:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[toto]}]}, environment: null}
EXPECTED: AuthZ request does not contain any Subject
Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: x-urn:junit:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[hello]}]}], resources:[], action: Action{ attributes:[Attribute{ id: x-urn:junit:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[toto]}]}, environment: null}
EXPECTED: AuthZ request does not contain any Resource
Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: x-urn:junit:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[hello]}]}], resources:[Resource{ content: null, attributes:[Attribute{ id: x-urn:junit:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[titi]}]}], action: null, environment: null}
EXPECTED: AuthZ request does not contain an Action
Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: x-urn:junit:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[hello]}]}], resources:[Resource{ content: null, attributes:[Attribute{ id: x-urn:junit:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[titi]}]}], action: Action{ attributes:[]}, environment: null}
EXPECTED: AuthZ request Action without any attribute
Request{ subjects:[Subject{ category: null, attributes:[]}], resources:[Resource{ content: null, attributes:[Attribute{ id: x-urn:junit:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[titi]}]}], action: Action{ attributes:[Attribute{ id: x-urn:junit:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[toto]}]}, environment: null}
EXPECTED: AuthZ request Subject without any attribute
Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: x-urn:junit:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[hello]}]}], resources:[Resource{ content: null, attributes:[]}], action: Action{ attributes:[Attribute{ id: x-urn:junit:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[toto]}]}, environment: null}
EXPECTED: AuthZ request Resource without any attribute
Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: x-urn:junit:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[hello]}]}], resources:[Resource{ content: null, attributes:[Attribute{ id: x-urn:junit:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[titi]}]}], action: Action{ attributes:[Attribute{ id: x-urn:junit:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[null, toto]}]}, environment: null}
EXPECTED: AuthZ request Action contains the attribute x-urn:junit:action-id with a null value
Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: x-urn:junit:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[null, hello]}]}], resources:[Resource{ content: null, attributes:[Attribute{ id: x-urn:junit:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[titi]}]}], action: Action{ attributes:[Attribute{ id: x-urn:junit:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[toto]}]}, environment: null}
EXPECTED: AuthZ request Subject contains the attribute x-urn:junit:subject-id with a null value
Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: x-urn:junit:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[hello]}]}], resources:[Resource{ content: null, attributes:[Attribute{ id: x-urn:junit:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[null, titi]}]}], action: Action{ attributes:[Attribute{ id: x-urn:junit:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[toto]}]}, environment: null}
EXPECTED: AuthZ request Resource contains the attribute x-urn:junit:resource-id with a null value
Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: x-urn:junit:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[hello]}]}], resources:[Resource{ content: null, attributes:[Attribute{ id: x-urn:junit:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[titi]}]}], action: Action{ attributes:[Attribute{ id: x-urn:junit:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[toto,  ]}]}, environment: null}
EXPECTED: AuthZ request Action contains the attribute x-urn:junit:action-id with an empty (stripped) value
Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: x-urn:junit:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[, hello]}]}], resources:[Resource{ content: null, attributes:[Attribute{ id: x-urn:junit:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[titi]}]}], action: Action{ attributes:[Attribute{ id: x-urn:junit:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[toto]}]}, environment: null}
EXPECTED: AuthZ request Subject contains the attribute x-urn:junit:subject-id with an empty (stripped) value
Request{ subjects:[Subject{ category: null, attributes:[Attribute{ id: x-urn:junit:subject-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[hello]}]}], resources:[Resource{ content: null, attributes:[Attribute{ id: x-urn:junit:resource-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[     , titi]}]}], action: Action{ attributes:[Attribute{ id: x-urn:junit:action-id, dataType: http://www.w3.org/2001/XMLSchema#string, issuer: null, values:[toto]}]}, environment: null}
EXPECTED: AuthZ request Resource contains the attribute x-urn:junit:resource-id with an empty (stripped) value
Tests run: 13, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.021 sec "
echo "---"
echo "OK"
echo "-------------------------------"



if [ $passed == "no" ]; then
echo "---Test: PIP to validate request: TEST FAILED---"
echo `date`
exit 1
else
echo "---Test: PIP to validate request: TEST PASSED---"
echo `date`
exit 0
fi
