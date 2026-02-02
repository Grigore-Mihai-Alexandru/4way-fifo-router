onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk_i
add wave -noupdate /testbench/rst_ni
add wave -noupdate -expand -group {Interfata intrare} -radix hexadecimal /testbench/data_i
add wave -noupdate -expand -group {Interfata intrare} -radix unsigned /testbench/valid_i
add wave -noupdate -expand -group {Interfata intrare} -radix unsigned /testbench/ready_o
add wave -noupdate -expand -group {Memorie FIFO} -radix hexadecimal -childformat {{{/testbench/dut/fifo_mem[0]} -radix hexadecimal} {{/testbench/dut/fifo_mem[1]} -radix hexadecimal} {{/testbench/dut/fifo_mem[2]} -radix hexadecimal} {{/testbench/dut/fifo_mem[3]} -radix hexadecimal}} -subitemconfig {{/testbench/dut/fifo_mem[0]} {-height 15 -radix hexadecimal} {/testbench/dut/fifo_mem[1]} {-height 15 -radix hexadecimal} {/testbench/dut/fifo_mem[2]} {-height 15 -radix hexadecimal} {/testbench/dut/fifo_mem[3]} {-height 15 -radix hexadecimal}} /testbench/dut/fifo_mem
add wave -noupdate -expand -group {Interfata iesire} -radix binary /testbench/ready_i
add wave -noupdate -expand -group {Interfata iesire} -radix binary /testbench/valid_o
add wave -noupdate -expand -group {Interfata iesire} -radix hexadecimal -childformat {{{/testbench/data_o[3]} -radix unsigned} {{/testbench/data_o[2]} -radix unsigned} {{/testbench/data_o[1]} -radix unsigned} {{/testbench/data_o[0]} -radix unsigned}} -subitemconfig {{/testbench/data_o[3]} {-height 15 -radix unsigned} {/testbench/data_o[2]} {-height 15 -radix unsigned} {/testbench/data_o[1]} {-height 15 -radix unsigned} {/testbench/data_o[0]} {-height 15 -radix unsigned}} /testbench/data_o
add wave -noupdate -expand -group {Nr. elemente si Fifo-full} -radix unsigned /testbench/dut/fifo_inst/no_of_elements
add wave -noupdate -expand -group {Nr. elemente si Fifo-full} /testbench/dut/fifo_full_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {51 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 205
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {121 ns}
