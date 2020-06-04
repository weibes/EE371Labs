onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /blockDrawer_testbench/Clock
add wave -noupdate /blockDrawer_testbench/Reset
add wave -noupdate /blockDrawer_testbench/enable
add wave -noupdate /blockDrawer_testbench/dataIn
add wave -noupdate /blockDrawer_testbench/blackNotWhite
add wave -noupdate /blockDrawer_testbench/rdaddress
add wave -noupdate -radix unsigned /blockDrawer_testbench/x
add wave -noupdate -radix unsigned /blockDrawer_testbench/y
add wave -noupdate -expand -group internals /blockDrawer_testbench/dut/ps
add wave -noupdate -expand -group internals /blockDrawer_testbench/dut/ns
add wave -noupdate -expand -group internals -radix unsigned /blockDrawer_testbench/dut/xBlockCoord
add wave -noupdate -expand -group internals -radix unsigned /blockDrawer_testbench/dut/yBlockCoord
add wave -noupdate -expand -group internals -radix unsigned /blockDrawer_testbench/dut/xInternal
add wave -noupdate -expand -group internals -radix unsigned /blockDrawer_testbench/dut/yInternal
add wave -noupdate -group nexts -radix unsigned /blockDrawer_testbench/dut/nextXBlockCoord
add wave -noupdate -group nexts -radix unsigned /blockDrawer_testbench/dut/nextYBlockCoord
add wave -noupdate -group nexts -radix unsigned /blockDrawer_testbench/dut/nextXInternal
add wave -noupdate -group nexts -radix unsigned /blockDrawer_testbench/dut/nextYInternal
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1362 ps} 0}
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
WaveRestoreZoom {5795 ps} {6795 ps}
