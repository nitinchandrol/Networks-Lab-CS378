#Set various configuration paramters for the 802.3 simulation
#"opt" is a sort of a "structure" or "object" which holds the various
#configuration parameters. The "field" name is in parantheses and
#its default value is set

set opt(bw)	1Mb;  # Date rate of the shared medium (bus)
set opt(delay)	0ms;  #Some delay you should ignore
set opt(ll)	LL;    #The logical link layer- ignore
set opt(ifq)	Queue/DropTail;   #This says that the interface queue
                                  #drops new arrival packets if buffer is full
set opt(mac)	Mac/802_3;  # Declaring the Media Access Control to be 802.3
set opt(chan)	Channel;    #Declaring that the link is a shared channel
set opt(nn) 5;              #number of nodes
set opt(seed) 12345;        #seed for the experiment. 802.3 requires
                            #random numbers
set opt(flowfin) 10.5;      #Time when CBR flows finish
set opt(simfin) 16.5;       #Time when simulation finishes


#Print out usage if options are not given
proc usage {} {
    global argv0
    puts "Usage: $argv0 \[-nn NumberNodes\] \[-seed Seed\] \n"
    exit 1
}

#The function to retrive the "nn" and the "seed" options from the
#command line
proc getopt {argc argv} {
    global opt
    lappend optlist seed nn
    if {$argc < 4} usage
    for {set i 0} {$i < $argc} {incr i} {
	set arg [lindex $argv $i]
	if {[string range $arg 0 0 ] != "-"} continue
	set name [string range $arg 1 end]
        set opt($name) [lindex $argv [expr $i+1]]
        }
}

#Interface buffer size
#Uncomment and lay with this if you want - not really required for the lab.
#Queue set limit_ $opt(nn)

#Call the function which sets nn and seed from command line 
getopt $argc $argv

#Redundant comment: procedure for creating the topology
proc create-topology {} {
	global ns opt
	global lan node
        set num $opt(nn)

#Create list of nodes that will be a part of the Ethernet LAN

	for {set i 0} {$i <= $num} {incr i} {
		set node($i) [$ns node]
		lappend nodelist $node($i)		
	}
   
#Create the LAN with all the options we set above or from command line

	set lan [$ns newLan $nodelist $opt(bw) $opt(delay) \
			-llType $opt(ll) -ifqType $opt(ifq) \
			-macType $opt(mac) -chanType $opt(chan) -macTrace ON ]
 
#Weird hack required to get NAM to show the picture nicely. Feel free
#to remove the next three lines if you like zig-zag looking network figures.
    set nodeForView [$ns node]
    $ns duplex-link $nodeForView $node(0) 10Mb 2ms DropTail
    $ns duplex-link-op $nodeForView $node(0) orient right
}

#Redundant comment: procedure for creating the traffic
proc create-traffic {} {
    global ns opt
    global lan node
    set num $opt(nn)

#For all all the nodes, we need to creata an UDP agent, attach it to
#the node. Then create a CBR flow and attach it to the UDP
#agent. CBR flow paramters need to be defined. A sink (Null) needs to be
#defined for each flow - whic is node0 for all the flows. All this
#is being done in this loop.
    for {set i 1} {$i <= $num} {incr i} {
	set udp_($i) [new Agent/UDP]
	$ns attach-agent $node($i) $udp_($i)
	set null_($i) [new Agent/Null]
	$ns attach-agent $node(0) $null_($i)
	
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ 1000
	set rate 100Kb
	$cbr_($i) set rate_ $rate
	$cbr_($i) attach-agent $udp_($i)
	$ns connect $udp_($i) $null_($i)
	$ns at 0.5 "$cbr_($i) start"
	$ns at $opt(flowfin) "$cbr_($i) stop"
    }
#Uncomment this if you want to change the CBR rate of Node 1
#    $cbr_(1) set rate_ 400Kb
}

#Define a 'finish' procedure
proc finish {} {

#Remember to comment this out when you start doing lots of
#experiments. Else you will spend a good part of the lab killing
#nam windows.
	exec nam out.nam &
        exit 0
}


#Create a simulator object
set ns [new Simulator]
ns-random $opt(seed)

set nf [open out.nam w]
$ns namtrace-all $nf

set tracefd     [open csmacd.tr w]
$ns trace-all   $tracefd

create-topology
create-traffic

$ns at $opt(simfin) "finish"

#Run the simulation
$ns run

