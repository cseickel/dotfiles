#!/bin/bash                                                                                                                                                                                                                                                                                                                                                                                   
ID=$(cat /root/.HIBERNATE_JOB_ID 2>/dev/null)                          
HIBERNATE_JOB_ID="${ID:-0}"                                                                   
                                                            
is_ssh_connected() {                                                           
    netstat | grep ssh | grep ESTABLISHED >> /dev/null;
}

if is_ssh_connected; then
    if [ $HIBERNATE_JOB_ID -gt 0 ]; then
    echo "cancelling hibernation"
    atrm $HIBERNATE_JOB_ID
    rm /root/.HIBERNATE_JOB_ID
    else
    echo "ssh connected, not doing anything"
    fi
else
    if [ $HIBERNATE_JOB_ID -lt 1 ]; then
    echo "scheduling hibernation"
    HIBERNATE_JOB_ID=`at now + 30 minutes -f /root/hibernate-me.sh 2>&1 | awk '/job/ {print $2}'`
    echo $HIBERNATE_JOB_ID > /root/.HIBERNATE_JOB_ID
    else
    echo "Hibernation already scheduled: $HIBERNATE_JOB_ID"
    fi
fi
