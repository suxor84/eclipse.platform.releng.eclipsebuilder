#!/usr/bin/env bash

function sendPromoteMail ()
{

eclipseStream=$1
if [ -z "${eclipseStream}" ]
then
    echo "must provide eclispeStream as first argumnet"
    exit 1;
fi


buildType=$2
if [ -z "${buildType}" ]
then
    echo "must provide buildType as second argumnet"
    exit 1;
fi
buildId=$3
if [ -z "${buildId}" ]
then
    echo "must provide buildId as third argumnet"
    exit 1;
fi

# ideally, the user executing this mail will have this special file in their home direcotry,
# that can specify a custom 'from' variable, but still you must use your "real" ID that is subscribed
# to the wtp-dev mailing list
#   set from="\"Your Friendly WTP Builder\" <real-subscribed-id@real.address>"
# correction ... doesn't work. Seems the subscription system set's the "from" name, so doesn't work when 
# sent to mail list (just other email addresses)
# espeically handy if send from one id (e.g. "david_williams)
export MAILRC=~/.e4Buildmailrc

# common part of URL and file path
# varies by build stream
# examples of end result:
# http://download.eclipse.org/eclipse/downloads/drops4/N20120415-2015/
# /home/data/httpd/download.eclipse.org/eclipse/downloads/drops4/N20120415-2015
mainPath=eclipse/downloads/drops4

downloadURL=http://download.eclipse.org/${mainPath}/${buildId}/



# 4.2 Build: I20120411-2034
SUBJECT="${eclipseStream} ${buildType}-Build: ${buildId}"

# wtp-dev for promotes, wtp-releng for smoketest requests
#TO="platform-releng-dev@eclipse.org"
# for tests
#TO="david_williams@us.ibm.com"

#make sure reply to goes back to the list
REPLYTO="platform-releng-dev@eclipse.org"
#we could? to "fix up" TODIR since it's in file form, not URL
# URLTODIR=${TODIR##*${DOWNLOAD_ROOT}}


mail -s "${SUBJECT}" -R "${REPLYTO}" "${TO}"  <<EOF   
Download:
${downloadURL}
Software site repository:
http://download.eclipse.org/eclipse/updates/${eclipseStream}-${buildType}-builds
EOF

echo "mail sent for $eclipseStream $buildType-build $buildId"

}



sendPromoteMail $1 $2 $3
