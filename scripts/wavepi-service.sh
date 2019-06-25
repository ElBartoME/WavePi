#!/bin/bash
## This script is meant to be installed as a service script for systemd (or init.d) to use.
## it currently can't pull proper the status from anything but w/e

### BEGIN INIT INFO
# Provides:          wavepi
# Required-Start:    $syslog
# Required-Stop:     
# Should-Start:      
# Default-Start:     2 3 4 5
# Default-Stop:      
# Short-Description: MIDI Synth frontend script
# Description:       WavePi runs as a frontend for several MIDI services
#                    like Fluidsynth and Munt.
#                    This service helps provide sysex profile switching.
### END INIT INFO

## DEFINE VARIBLES ##

CURRENT_DIR=$(dirname $(readlink -f $0))
## Read varibles from main.cfg
source $CURRENT_DIR/../configs/main.cfg
## set process priority level (nice number), the range is -20 - 18, lower the number, the higher the priority.
NICE_LEVEL=-18
## s

## DEFINE FUNCTIONS ##

status ()
{
    ## load varibles from all log files...
    source $CURRENT_DIR/../logs/current-synth-info.log
    ## other log files go here...

    ## do some simple logic
    WAVE_PI_RUNNING="OFF"
    if [ "$RUNNING_PID" != "-1" ]
    then
        WAVE_PI_RUNNING="RUNNING"
    fi

    ## start printing out statuses...
    echo "WavePi Synth status is currently - $RUNNING_SYNTH_NAME"
    echo "WavePi Synth is currently $WAVE_PI_RUNNING"
    if [ "$WAVE_PI_RUNNING" == "RUNNING" ]
    then
        echo "WavePi Synth PID number is $RUNNING_PID"
    fi
    ## other script status stuff to go in here...
}

start ()
{
    nice -n $NICE_LEVEL sudo -u $WAVEPI_USER $CURRENT_DIR/wavepi.sh $DEFAULT_CONFIG

    ## Check if RGB is enabled and run RGB script if it is...
    if [ "$RGB" == "true" ] || [ "$RGB" == "TRUE" ] || [ "$RGB" == "YES" ] || [ "$RGB" == "yes" ] || [ "$RGB" == "1" ]
    then
        sudo -u $WAVEPI_USER $CURRENT_DIR/midirgb.sh &
    fi
}

stop ()
{
    sudo -u $WAVEPI_USER $CURRENT_DIR/wavepi.sh stop

    ## other stop scripts for other stuff...
}

## DEFINE MAIN PROGRAM

## simple elseif tree for $1 command
if [ "$1" == "start" ] || [ "$1" == "START" ]
then
    start
    sleep 2
    status

## If $1 is STOP, stop synth and print status when done...
elif [ "$1" == "stop" ] || [ "$1" == "STOP" ]
then
    stop
    sleep 2
    status

## If $1 is RESTART, stop then start synth and print status when done...
elif [ "$1" == "restart" ] || [ "$1" == "RESTART" ]
then
    echo "stopping......."
    stop
    sleep 2
    echo "starting......."
    start
    sleep 2
    status

## If $1 is STATUS, print status...
elif [ "$1" == "status" ] || [ "$1" == "STATUS" ]
then
    echo "printing status...."
    status

## print error if command not recognized
else
    echo "INVALID REQUEST! DOING NOTHING"
fi
