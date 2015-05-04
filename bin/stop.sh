#!/bin/bash
##
#
# Copyright 2010-2013 by David A. Parker <parker.david.a@gmail.com>
# 
# This file is part of CheckValve, an HLDS/SRCDS query app for Android.
# 
# CheckValve is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
# 
# CheckValve is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with the CheckValve source code.  If not, see
# <http://www.gnu.org/licenses/>.
#
##

##
#
# PROGRAM:
# stop.sh
#
# DESCRIPTION:
# Stop an instance of CheckValve Chat Relay.
#
# AUTHOR:
# Dave Parker
#
# CHANGE LOG:
#
# November 14, 2013
# - Initial release.
#
# May 4, 2015
# - Set the value of $BASEDIR automatically.
#

##
#
# Store the current working directory
#
OLD_PWD=$(pwd)

##
#
# Set the CheckValve Chat Relay base directory
#
THISDIR=$(basename $0)
cd ${THISDIR}/../
BASEDIR=$(pwd)
cd ${OLD_PWD}

##
#
# PID and JAR files for CheckValve Chat Relay
#
JARFILE="${BASEDIR}/lib/checkvalvechatrelay.jar"
PIDFILE="${BASEDIR}/checkvalvechatrelay.pid"

# Make sure the PID file exists
if [ ! -f $PIDFILE ] ; then
    echo >&2
    echo "ERROR: PID file $PIDFILE does not exist." >&2
    echo >&2
    exit 1
fi

TARGET_PID=$(cat $PIDFILE)

# Make sure the PID file is not empty
if [ -z $TARGET_PID ] ; then
    echo >&2
    echo "ERROR: PID file $PIDFILE is empty." >&2
    echo >&2
    exit 1
fi

# Make sure the PID file is writable
if (! touch ${PIDFILE} >/dev/null 2>&1) ; then
    echo >&2
    echo "ERROR: PID file ${PIDFILE} is not writable." >&2
    echo >&2
    exit 1
fi

# Make sure CheckValve Chat Relay is running on the PID obtained from the PID file
if (ps -ef | grep -w $TARGET_PID | grep -m1 -v grep | grep $JARFILE >/dev/null) ; then
    kill -TERM $TARGET_PID

    if [ $? -eq 0 ] ; then
        echo "Stopped CheckValve Chat Relay."
        >$PIDFILE
        exit 0
    else
        echo "Failed to stop CheckValve Chat Relay (PID $TARGET_PID)."
        exit 1
    fi
else
    echo >&2
    echo "ERROR: Value in PID file is $TARGET_PID, but CheckValve Chat Relay" >&2
    echo "       is not running on this PID." >&2
    echo >&2
fi

exit 0
