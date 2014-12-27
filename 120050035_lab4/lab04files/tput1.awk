
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
# 8. Flow ID
# 9-10. Source Address and Destination Address: addresses of the  CONNECTION end-points in a "node_id.port_number" format. 
# 11. Sequence Number
# 12. Packet Unique ID


# Use awk field variables to select the lines you want to process. 

# Throughput of the flow from Node 2 
# CHANGE $9 for finding the flow of another node - or improve this
# code to give all individual node flows  
    ($1 == "r") && ($9==2.0) {total_data_received += $6; time_of_last_reception = $2; num_packs++ }
END {
    flow_start_time = 0.5; # configured in the tcl file, change here if you change it there;
    total_time_taken = time_of_last_reception -  flow_start_time ;
#    print total_data_received, time_of_last_reception, num_packs;
    print "throughput =",  total_data_received*8/(total_time_taken*1000), "Kbps";
    }

	
	
	   
