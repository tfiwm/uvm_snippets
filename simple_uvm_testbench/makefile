all: comp sim

comp: test.sv
	vlog -L uvm-1.1d +incdir+${UVM_HOME}/src test.sv
sim:
	vsim test -L uvm-1.1d -do "run -all; quit" -c
