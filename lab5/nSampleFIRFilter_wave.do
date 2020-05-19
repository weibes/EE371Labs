onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /nSampleFIRFilter_testbench/Clock
add wave -noupdate /nSampleFIRFilter_testbench/wren
add wave -noupdate /nSampleFIRFilter_testbench/reen
add wave -noupdate -radix decimal /nSampleFIRFilter_testbench/dataIn
add wave -noupdate -radix decimal /nSampleFIRFilter_testbench/dataOut
add wave -noupdate -expand -group internalVals -radix decimal /nSampleFIRFilter_testbench/dut/dataNormalized
add wave -noupdate -expand -group internalVals -radix decimal /nSampleFIRFilter_testbench/dut/dataBuffer
add wave -noupdate -expand -group internalVals -radix decimal /nSampleFIRFilter_testbench/dut/dataSumBuffer
add wave -noupdate -expand -group internalVals -radix decimal /nSampleFIRFilter_testbench/dut/dataDelayed
add wave -noupdate -expand -group delay_adder /nSampleFIRFilter_testbench/dut/delay/Clock
add wave -noupdate -expand -group delay_adder /nSampleFIRFilter_testbench/dut/delay/enable
add wave -noupdate -expand -group delay_adder /nSampleFIRFilter_testbench/dut/delay/D
add wave -noupdate -expand -group delay_adder /nSampleFIRFilter_testbench/dut/delay/Q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {177 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
