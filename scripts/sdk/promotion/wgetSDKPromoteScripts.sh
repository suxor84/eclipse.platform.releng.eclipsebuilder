#!/usr/bin/env bash

#Sample utility to wget files related to promotion


# we say "branch or tag", but for tag, the wget has to use tag= instead of h=
branchOrTag=master

# remember that wget puts most its output on "standard error", I assume
# following the philosophy that anything "diagnosic" related goes to standard err,
# and only things the user really needs wants to see as "results" goes to standard out
# but in cron jobs and similar, this comes across as "an error".

wget --no-verbose -O syncDropLocation.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/promotion/syncDropLocation.sh?h=$branchOrTag 2>&1
wget --no-verbose -O sdkPromotionCronJob.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/promotion/sdkPromotionCronJob.sh?h=$branchOrTag 2>&1
wget --no-verbose -O updateDropLocation.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/promotion/updateDropLocation.sh?h=$branchOrTag 2>&1
wget --no-verbose -O getBaseBuilder.xml http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/promotion/getBaseBuilder.xml?h=$branchOrTag 2>&1
wget --no-verbose -O getEBuilder.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/promotion/getEBuilder.sh?h=$branchOrTag 2>&1

wget --no-verbose -O wgetSDKPromoteScripts.NEW.sh http://git.eclipse.org/c/platform/eclipse.platform.releng.eclipsebuilder.git/plain/scripts/sdk/promotion/wgetSDKPromoteScripts.sh?h=$branchOrTag 2>&1

differs=`diff wgetSDKPromoteScripts.NEW.sh wgetSDKPromoteScripts.sh`

if [ -z "${differs}" ]
then
    # 'new' not different from existing, so remove 'new' one
    rm wgetSDKPromoteScripts.NEW.sh
else
    echo " "
    echo "     wgetSDKPromoteScripts.sh has changed. Compare with and consider replacing with wgetSDKPromoteScripts.NEW.sh"
    echo "differs: ${differs}"
    echo "  "
fi

chmod +x *.sh
