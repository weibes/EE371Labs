onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /displayDriver_testbench/Clock
add wave -noupdate /displayDriver_testbench/Reset
add wave -noupdate /displayDriver_testbench/dataIn
add wave -noupdate /displayDriver_testbench/rdaddress
add wave -noupdate -expand -group internals -radix unsigned /displayDriver_testbench/dut/x
add wave -noupdate -expand -group internals -radix unsigned /displayDriver_testbench/dut/y
add wave -noupdate -expand -group internals /displayDriver_testbench/dut/pixel_color
add wave -noupdate -expand -group internals /displayDriver_testbench/dut/ps
add wave -noupdate -group nextx -radix unsigned /displayDriver_testbench/dut/nextX
add wave -noupdate -group nextx -radix unsigned /displayDriver_testbench/dut/nextY
add wave -noupdate -group nextx /displayDriver_testbench/dut/next_pixel_color
add wave -noupdate -group nextx /displayDriver_testbench/dut/ns
add wave -noupdate -group boardInternals -radix unsigned /displayDriver_testbench/dut/xBoard
add wave -noupdate -group boardInternals -radix unsigned /displayDriver_testbench/dut/yBoard
add wave -noupdate -group boardInternals /displayDriver_testbench/dut/boardDone
add wave -noupdate -group boardInternals /displayDriver_testbench/dut/BNWBoard
add wave -noupdate -group blockInternals -radix unsigned /displayDriver_testbench/dut/xBlocks
add wave -noupdate -group blockInternals -radix unsigned /displayDriver_testbench/dut/yBlocks
add wave -noupdate -group blockInternals /displayDriver_testbench/dut/BNWBlocks
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5760313 ps} 0}
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
WaveRestoreZoom {5760145 ps} {5761145 ps}
