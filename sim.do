vlog -reportprogress 300 -work work *.sv
vsim -gui work.testbench
log -r *
do wave.do
run -all