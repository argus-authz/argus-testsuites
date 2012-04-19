#!/bin/sh

#########################################################
# Test if the Services are present on the system and setting some variables
# This is done for every test, even if the variables are not needed
if [ -z $PAP_HOME ]; then
    if [ -d /usr/share/argus/pap ]; then
        export PAP_HOME=/usr/share/argus/pap
    else
        echo "PAP_HOME not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

if [ -z $PAP_CTRL ]; then
    if [ -f /etc/init.d/argus-pap ]
        export PAP_CTRL=/etc/init.d/argus-pap
    else
        echo "PAP_CTRL not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

if [ -z $PDP_HOME ]; then
    if [ -d /usr/share/argus/pdp ]; then
        export PDP_HOME=/usr/share/argus/pdp
    else
        echo "PDP_HOME not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

if [ -z $PDP_CTRL ]; then
    if [ -f /etc/init.d/argus-pdp ]
        export PDP_CTRL=/etc/init.d/argus-pdp
    else
        echo "PDP_CTRL not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

if [ -z $PEP_HOME ]; then
    if [ -d /usr/share/argus/pepd ]; then
        export PEP_HOME=/usr/share/argus/pepd
    else
        echo "PEP_HOME not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

if [ -z $PEP_CTRL ]; then
    if [ -f /etc/init.d/argus-pepd ]
        export PEP_CTRL=/etc/init.d/argus-pepd
    else
        echo "PEP_CTRL not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi
#########################################################