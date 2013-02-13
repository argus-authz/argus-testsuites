#!/bin/bash

#########################################################
# Test if the Services are present on the system and setting some variables
# This is done for every test, even if the variables are not needed
if [ -z $T_PAP_HOME ]; then
    if [ -d /usr/share/argus/pap ]; then
        export T_PAP_HOME=/usr/share/argus/pap
    else
        echo "T_PAP_HOME not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

if [ -z $T_PAP_CTRL ]; then
    if [ -x /etc/init.d/argus-pap ]; then
        export T_PAP_CTRL=/etc/init.d/argus-pap
    else
        echo "T_PAP_CTRL not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

if [ -z $T_PDP_HOME ]; then
    if [ -d /usr/share/argus/pdp ]; then
        export T_PDP_HOME=/usr/share/argus/pdp
    else
        echo "T_PDP_HOME not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

if [ -z $T_PDP_CTRL ]; then
    if [ -x /etc/init.d/argus-pdp ]; then
        export T_PDP_CTRL=/etc/init.d/argus-pdp
    else
        echo "T_PDP_CTRL not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

if [ -z $T_PEP_HOME ]; then
    if [ -d /usr/share/argus/pepd ]; then
        export T_PEP_HOME=/usr/share/argus/pepd
    else
        echo "T_PEP_HOME not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi

if [ -z $T_PEP_CTRL ]; then
    if [ -x /etc/init.d/argus-pepd ]; then
        export T_PEP_CTRL=/etc/init.d/argus-pepd
    else
        echo "T_PEP_CTRL not set, not found at standard locations. Exiting."
        exit 2;
    fi
fi
#########################################################
