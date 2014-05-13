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

short_usage()
{
    echo "Usage: $0 [--minheap <size>] [--maxheap <size>] [--debug [--debughost <ip>] [--debugport <port>]]"
    echo "       $0 [--help|-h|-?]"
}

long_usage()
{
    echo
    short_usage
    echo
    echo "Command-line options:"
    echo
    echo "  --minheap <size>    Set the JVM's minimum heap size to <size> [default = ${JVM_MIN_MEM}]"
    echo "  --maxheap <size>    Set the JVM's maximum heap size to <size> [default = ${JVM_MAX_MEM}]"
    echo "  --debug             Enable the Java debugging listener (for use with jdb)"
    echo "  --debughost <ip>    IP for jdb connections if debugging is enabled [default = ${DEBUG_HOST}]"
    echo "  --debugport <port>  Port for jdb connections if debugging is enabled [default = ${DEBUG_PORT}]"
    echo "  --help | -h | -?    Show this help text and exit"
    echo
    echo "Note: For --minheap and --maxheap, the <size> value should be a number followed by k, m, or g"
    echo "      kilobytes, megabytes, or gigabytes, respectively.  (Ex: 1048576k, 1024m, 1g)."
    echo
}

start_debug()
{
    # Set the JVM debugging options
    DEBUG_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=${DEBUG_HOST}:${DEBUG_PORT}"

    # Start CheckValve Chat Relay with debug options and save its PID to the PID file
    ${JAVA_BIN} ${DEBUG_OPTS} -Xms${JVM_MIN_MEM} -Xmx${JVM_MAX_MEM} -jar ${JARFILE} >/dev/null &
    echo "$!" > ${PIDFILE}
    echo "Started CheckValve Chat Relay."
    echo "(Debugging mode is enabled, connect jdb to ${DEBUG_HOST}:${DEBUG_PORT} for debugging)."
}

start_no_debug()
{
    # Start CheckValve Chat Relay and save its PID to the PID file
    ${JAVA_BIN} -Xms${JVM_MIN_MEM} -Xmx${JVM_MAX_MEM} -jar ${JARFILE} &
    echo "$!" > ${PIDFILE}
    echo "Started CheckValve Chat Relay."
}

##
#
# CheckValve Chat Relay base directory
#
BASEDIR="/usr/local/CheckValveChatRelay"

##
#
# Default debugging options
#
DEBUG="0"
DEBUG_HOST="localhost"
DEBUG_PORT="1044"
DEBUG_OPTS=""

##
#
# Default minimum heap size for CheckValve Chat Relay
#
JVM_MIN_MEM="8m"

##
#
# Default maximum heap size for CheckValve Chat Relay
#
JVM_MAX_MEM="16m"

##
#
# JAR and PID files for CheckValve Chat Relay
#
JARFILE="${BASEDIR}/lib/checkvalvechatrelay.jar"
PIDFILE="${BASEDIR}/checkvalvechatrelay.pid"

# If a bundled JRE is present then add it to the PATH
if [ -d ${BASEDIR}/jre ] ; then
    PATH="${PATH}:${BASEDIR}/jre/bin"
    export PATH

    # Set JAVA_HOME if it is not already set
    if [ -z JAVA_HOME ] ; then
        JAVA_HOME="${BASEDIR}/jre"
        export JAVA_HOME
    fi
fi

##
#
# Java executable
#
JAVA_BIN=$(which java)

# Set options from the command line
while [ "$1" ] ; do
    case $(echo "$1" | tr A-Z a-z) in
        '--debug')
            DEBUG="1"
            shift
            ;;
        '--debughost')
            if [ ! $2 ] ; then
                echo "You must supply a value for --debughost"
                short_usage
                exit 1
            fi
            DEBUG_HOST="$2"
            shift ; shift
            ;;
        '--debugport')
            if [ ! $2 ] ; then
                echo "You must supply a value for --debugport"
                short_usage
                exit 1
            fi
            DEBUG_PORT="$2"
            shift ; shift
            ;;
        '--minheap')
            if [ ! $2 ] ; then
                echo "You must supply a value for --minheap"
                short_usage
                exit 1
            fi
            JVM_MIN_MEM="$2"
            shift ; shift
            ;;
        '--maxheap')
            if [ ! $2 ] ; then
                echo "You must supply a value for --maxheap"
                short_usage
                exit 1
            fi
            JVM_MAX_MEM="$2"
            shift ; shift
            ;;
        '--help'|'-h'|'-?')
            long_usage
            exit 1
            ;;
        *)
            echo "Invalid option: $1"
            short_usage
            exit 1
            ;;
    esac
done

# Make sure the JAR file exists
if [ ! -f ${JARFILE} ] ; then
    echo >&2
    echo "ERROR: The file ${JARFILE} does not exist." >&2
    echo >&2
    exit 1
fi

# Make sure the PID file is writable
if (! touch ${PIDFILE} >/dev/null 2>&1) ; then
    echo >&2
    echo "ERROR: The file ${PIDFILE} is not writable." >&2
    echo >&2
    exit 1
fi

# Make sure the 'java' command is in the PATH
if [ "$JAVA_BIN" = "" ] ; then
    echo >&2
    echo "ERROR: Unable to locate the 'java' executable.  Please ensure" >&2
    echo "       the Java Runtime Environment (JRE) is installed and" >&2
    echo "       the 'java' executable can be found in your PATH." >&2
    echo >&2
    exit 1
fi

# Make sure another instance is not already running
if [ -s ${PIDFILE} ] ; then
    TARGET_PID=$(cat ${PIDFILE})

    if (ps -ef | grep -w ${TARGET_PID} | grep -m1 -v grep | grep ${JARFILE} >/dev/null) ; then
        echo >&2
        echo "ERROR: CheckValve Chat Relay is already running on PID ${TARGET_PID}." >&2
        echo >&2
        exit 1
    else
        echo >&2
        echo "WARNING: Replacing stale PID file (perhaps left over from an unclean shutdown)." >&2
        echo >&2
    fi
fi

if [ "$DEBUG" = "1" ] ; then
    start_debug
else
    start_no_debug
fi

exit 0
