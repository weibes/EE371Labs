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
add wave -noupdate -expand -group blockInternals -radix decimal /displayDriver_testbench/dut/blocks/x
add wave -noupdate -expand -group blockInternals -radix decimal /displayDriver_testbench/dut/blocks/y
add wave -noupdate -expand -group blockInternals /displayDriver_testbench/dut/blocks/nextBlackNotWhite
add wave -noupdate -expand -group blockInternals -radix decimal /displayDriver_testbench/dut/blocks/nextX
add wave -noupdate -expand -group blockInternals -radix decimal /displayDriver_testbench/dut/blocks/nextY
add wave -noupdate -expand -group blockInternals -radix decimal /displayDriver_testbench/dut/blocks/xBlockCoord
add wave -noupdate -expand -group blockInternals -radix decimal /displayDriver_testbench/dut/blocks/nextXBlockCoord
add wave -noupdate -expand -group blockInternals -radix decimal /displayDriver_testbench/dut/blocks/yBlockCoord
add wave -noupdate -expand -group blockInternals -radix decimal /displayDriver_testbench/dut/blocks/nextYBlockCoord
add wave -noupdate -expand -group blockInternals -radix unsigned /displayDriver_testbench/dut/blocks/xInternal
add wave -noupdate -expand -group blockInternals -radix unsigned /displayDriver_testbench/dut/blocks/yInternal
add wave -noupdate -expand -group blockInternals -radix unsigned /displayDriver_testbench/dut/blocks/nextXInternal
add wave -noupdate -expand -group blockInternals -radix unsigned /displayDriver_testbench/dut/blocks/nextYInternal
add wave -noupdate -expand -group blockInternals /displayDriver_testbench/dut/blocks/ps
add wave -noupdate -expand -group blockInternals /displayDriver_testbench/dut/blocks/ns
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5762512 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 202
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
WaveRestoreZoom {5762374 ps} {5763324 ps}
