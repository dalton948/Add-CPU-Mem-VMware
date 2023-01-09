###########################
Read me for add_cpu_mem.ps1
###########################


Purpose: 
Simplify CPU & Memory Adds

How to use: 
1. Launch script (need to have an admin powershell window thats signed into Vsphers.)
2. Check for duplicates. (Sometimes VM(s) have a placeholder which adds an extra line and does not bode well with the script.)
3. Select Option 1 or 2.
	- Option 1: Processes one server at a time with user input. Required info is Server name, CPU to be added, and MEM to be added.
	Then it will cycle back through.
	- Option 2: Process a list of servers provided by user. Should be a simple text file with only the servers. 
	Only use this if the CPU & MEM that is asked to add are all the same value, like 8 CPUs and 32GB of memory are to 
	be added to each server listed.
	Example of list: "
	louappwpl203s02
	LOUSQLWPS1045
	LOUWEBWPL55S01
	"
4. Enter the amount of CPUs you're adding.
5. Enter the amount of Memory you're adding.
6. Confirm the values represent correctly.
7. Submit the changes.

What is the Script doing?
1. Gets current VM Data.
2. Checks for duplicates as Vsphere Placeholders break it
3. Stop the VM(s)- The script will exit if VM(s) are not powered off.
4. Enter added CPU & Memory values provided in Ticket.
5. Adds entered values to the VM's current values
6. Validate Data totals that are to be added.
7. Submit Data.
8. Start the VM(s)
9. Rinse/repeat.


Please get with Dalton D. if you have any questions.
