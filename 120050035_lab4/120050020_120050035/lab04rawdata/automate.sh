#/bin/bash 
for i in `seq 1 30`;
	do
		ns ns-csmacd.tcl -nn $i -seed 1234;
		awk -f tputAll.awk csmacd.tr >> outxx.txt;
	done
