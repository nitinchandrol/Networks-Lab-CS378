# Guide to the trace fields:

# 1  Type Identifier:
# "h": an "arrival at interface" event.
# “+”: a packet enque event
# “-”: a packet deque event
# “r”: a packet reception event
# “d”: a packet drop (e.g., sent to dropHead_) event

# 2. Time: at which the packet tracing string is created.
# 3-4. Source Node and Destination Node (link level)
# 5. Packet type: tcp/cbr 
# 6. Packet Size: Size of the packet in bytes.
# 7. Flags: A 7-digit flag string: "-------". 
# 8. Flow ID: 
# 9-10. Source Address and Destination Address: addresses of the  CONNECTION end-points in a "node_id.port_number" format. 
# 11. Sequence Number
# 12. Packet Unique ID


# Use awk field variables to select the lines you want to process. 


#This code generates a trace of delays of packets received at the sink
#node. It separately writes out the enque-to-deque time and the
#deque-to-packet arrival time


#For lines corresponding to enqueue events, we save the
#enqueueing times in an associative array indexed by packet ID
 ($1 == "+")  {
     enq_times[$12] = $2; num++;
 }

#For lines corresponding to dequeue events, we save the
#dequeueing times in an associative array indexed by packet ID
 ($1 == "-")  { 
    deq_times[$12] = $2; 
    num_deq++; 
    packd[num_deq]=$12;
 }


#For lines corresponding to the receive event, we save the
#packet reception time also in a similar associative
#array. Additionally, we need to save the IDs of the packets received
#in another array, and count the number of packets received.
 ($1 == "r")  { 
    rec_times[$12] = $2; 
    num_recd++; 
    packr[num_recd]=$12;
 }

 
END {

#Write out the delays for all received packets
    for (i=1; i <= num_recd; i++) {
	id = packr[i];        
	ifacedelay =  deq_times[id] - enq_times[id];	
	sumi += ifacedelay;
	travelDelay = rec_times[id] - deq_times[id];
	sumt +=travelDelay;
	print id,"   ", i," ", ifacedelay, travelDelay; 
    }
#print out average
    print "Num sent=", num, "Num recd = ", num_recd;
    print "Average iface delay = ", sumi/num_deq, "Average travel delay =", sumt/num_recd;
}
	
	
	   