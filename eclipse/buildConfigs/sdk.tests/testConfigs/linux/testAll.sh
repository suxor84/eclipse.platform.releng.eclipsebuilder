#!/bin/sh
cd .
#environment variables
PATH=$PATH:`pwd`/../linux;export PATH
#xhost +$HOSTNAME
MOZILLA_FIVE_HOME=/usr/lib/mozilla-1.7.12;export MOZILLA_FIVE_HOME
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MOZILLA_FIVE_HOME
USERNAME=`whoami`
#DISPLAY=$HOSTNAME:0.0
ulimit -c unlimited

export DISPLAY LD_LIBRARY_PATH

ls -la runtests.sh
#execute command to run tests
/bin/chmod 755 runtests.sh
ls -la runtests.sh
ls -la /shared/common/jdk-1.6.x86_64/jre/bin/java
./runtests.sh -os linux -ws gtk -arch x86_64 -vm /shared/common/jdk-1.6.x86_64/jre/bin/java -properties vm.properties > linux.gtk-6.0_consolelog.txt
exit 
