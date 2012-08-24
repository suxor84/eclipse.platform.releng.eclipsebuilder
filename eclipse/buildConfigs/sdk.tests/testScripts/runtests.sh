#!/usr/bin/env bash

echo "USER: $USER"
echo "PATH: $PATH"
# This file should never exist or be needed for production machine, 
# but allows an easy way for a "local user" to provide this file 
# somewhere on the search path ($HOME/bin is common), 
# and it will be included here, thus can provide "override values" 
# to those defined by defaults for production machine., 
# such as for vmcmd

source localTestsProperties.shsource


# by default, use the java executable on the path for outer and test jvm
vmcmd=${vmcmd:-/shared/common/jdk-1.6.x86_64/jre/bin/java}
#vmcmd=java

echo "vmcmd: $vmcmd"

#this value must be set when using rsh to execute this script, otherwise the script will execute from the user's home directory
dir=${PWD}

# operating system, windowing system and architecture variables
os=
ws=
arch=

# list of tests (targets) to execute in test.xml
tests=

# default value to determine if eclipse should be reinstalled between running of tests
installmode="clean"

# name of a property file to pass to Ant
properties=

# message printed to console
usage="usage: $0 -os <osType> -ws <windowingSystemType> -arch <architecture> [-noclean] [<test target>][-properties <path>]"


# proces command line arguments
while [ $# -gt 0 ]
do
    case "${1}" in
        -dir) 
            dir="${2}"; shift;;
        -os) 
            os="${2}"; shift;;
        -ws) 
            ws="${2}"; shift;;
        -arch) 
            arch="${2}"; shift;;
        -noclean) 
            installmode="noclean";;
        -properties) 
            properties="-propertyfile ${2}";shift;;
        -vm) 
            vmcmd="${2}"; shift;;
        *) 
            tests=$tests\ ${1};;
    esac
    shift
done

echo "Specified test targets (if any): ${tests}"

# for *nix systems, os, ws and arch values must be specified
if [ "x$os" = "x" ]
then
    echo >&2 "$usage"
    exit 1
fi

if [ "x$ws" = "x" ]
then
    echo >&2 "$usage"
    exit 1
fi

if [ "x$arch" = "x" ]
then
    echo >&2 "$usage"
    exit 1
fi

#necessary when invoking this script through rsh
cd $dir

# verify os, ws and arch values passed in are valid before running tests
if [ "$os-$ws-$arch" = "linux-gtk-x86" ] || [ "$os-$ws-$arch" = "macosx-cocoa-ppc" ] || [ "$os-$ws-$arch" = "macosx-cocoa-x86" ] || [ "$os-$ws-$arch" = "aix-gtk-ppc" ] || [ "$os-$ws-$arch" = "aix-gtk-ppc64" ]  || [ "$os-$ws-$arch" = "solaris-gtk-sparc" ] || [ "$os-$ws-$arch" = "solaris-gtk-x86" ] || [ "$os-$ws-$arch" = "linux-gtk-ppc64" ] ||  [ "$os-$ws-$arch" = "linux-gtk-ia64" ] ||  [ "$os-$ws-$arch" = "linux-gtk-x86_64" ] ||  [ "$os-$ws-$arch" = "hpux-gtk-ia64_32"]
then
    if [ ! -r eclipse ]
    then
        tar -xzf eclipse-SDK-*.tar.gz
        # note, the file pattern to match, must not start with */plugins because there is no leading '/' in the zip file, since they are repos.
        unzip -qq -o -C eclipse-junit-tests-*.zip plugins/org.eclipse.test* -d eclipse/dropins/
    fi

    # run tests
    launcher=`ls eclipse/plugins/org.eclipse.equinox.launcher_*.jar`
    
    echo "list all environment variables in effect as tests start"
    printenv
    
    echo "uname -a information"
    uname -a
    echo 
    
echo "cat /etc/lsb-release"
cat /etc/lsb-release

echo "cat /etc/SuSE-release"
cat /etc/SuSE-release

echo "rpm -q cairo"
rpm -q cairo

echo "rpm -q gtk2"
rpm -q gtk2

echo "rpm -q glibc"
rpm -q glibc

echo "rpm -q glib"
rpm -q glib

echo "rpm -q pango"
rpm -q pango

echo "rpm -q ORBit2"
rpm -q ORBit2

echo
    
    # make sure there is a window manager running. See bug 379026
    # we should not have to, but may be a quirk/bug of hudson setup
    # assuming metacity attaches to "current" display by default (which should have 
    # already been set by Hudson). We echo its value here just for extra reference/cross-checks.  
    echo "DISPLAY: $DISPLAY"
    metacity --replace --sm-disable  &
    METACITYPID=$!
    echo $METACITYPID > epmetacity.pid
    echo
    
    # list out metacity processes so overtime we can see if they accumulate, or if killed automatically 
    # when our process exits. If not automatic, should use epmetacity.pid to kill it when we are done.
    echo "Current metacity processes running:"
    ps -ef | grep "metacity" | grep -v grep
    echo 
    
    # -Dtimeout=300000 "${ANT_OPTS}"
    $vmcmd  -Dosgi.os=$os -Dosgi.ws=$ws -Dosgi.arch=$arch -jar $launcher -data workspace -application org.eclipse.ant.core.antRunner -file ${PWD}/test.xml $tests -Dws=$ws -Dos=$os -Darch=$arch -D$installmode=true $properties -logger org.apache.tools.ant.DefaultLogger

else
    # display message to user if os, ws and arch are invalid
    echo "The os, ws and arch values are either invalid or are an invalid combination"
    exit 1
fi

