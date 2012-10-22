#!/usr/bin/env bash

# cron job a committer can run, 
# say, every 15 minutes, or similar. If a
# collection script appears in the promoteLocation, then execute it, and if all goes
# well, then remove (or move) that collection script.   

# Note: if there are errors that occur during this cron job, they go to the 
# "default user" for that crontab, which may be what's desired, but you can also 
# set MAILTO in your crontab, cautiously, to send it where ever you'd like. 

# masterBuilder.sh must know about and use this same 
# location to put its collections scripts. (i.e. implicit tight coupling)
testdataLocation=/shared/eclipse/sdk/testjobdata

# Note: if we ever need to handle spaces, or newlines in names (seems unlikely) this 
# for loop won't quiet work, and will be more complicated (or, at least unintuitive). 

# Remember, do no call "exit" from for loop for normal cases, else 
# the whole script exits. Could use "continue" or "break" if needed.

allfiles=$( find $testdataLocation -name "testjobdata*.txt" )
for datafile in $allfiles 
do

    # having an echo here will cause cron job to send mail for EACH job, even if all is fine.
    # so use only for testing. 
    #echo $datafile

    if [[ -z "$datafile" ]] 
    then
        # nothing to do (Remember, can not have an empty if/then/else clause! Syntax error.
        echo "WARNING: odd condition where datafile variable had no value?"
    else 
        # found a file, confirm is file for safety
        if [[ -f $datafile ]]
        then 

            # if found a file to execute, temporarily change its name to "RUNNING-$datafile
            # so a subsequent cron job won't find it (if it does not finish by the time of the next cron job). 
            runningdatafile=$testdataLocation/RUNNING_$(basename $datafile)
            mv  $datafile $runningdatafile
            # notice these logs are concatenated on purpose, to give some "history", but
            # that means has to be "manually" removed every now and then. 
            # improve as desired.
            /bin/bash /shared/eclipse/sdk/collect.sh < $runningdatafile 1>>$testdataLocation/collection-out.txt 2>>$testdataLocation/collection-err.txt
            # to test cron job, without doing anything, comment out above line, and uncomment folloiwng line.
            # then try various types of files file names, etc. 
            # echo "DEBUG: normally would execute file here: $datafile" 1>>$testdataLocation/collection-out.txt 2>>$testdataLocation/datacollect-err.txt
            rccode=$?
            if [[ $rccode != 0 ]]
            then 
                echo "ERROR: collection returned an error: $rccode" 
                echo "       datafile: $datafile"
                mv $runningdatafile $testdataLocation/ERROR_$(basename $datafile)
                exit 1
            else
                # all is ok, we'll move the file to "RAN-" in case needed for later inspection, 
                # if things go wrong. Perhaps eventually just remove them?
                mv $runningdatafile $testdataLocation/RAN_$(basename $datafile)
            fi
        else
            echo "ERROR: data file found, but was not an actual file?"
            echo "         datafile: $datafile"
            exit 1
        fi
    fi
done

