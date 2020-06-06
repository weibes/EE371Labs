onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /boardDrawer_testbench/Clock
add wave -noupdate /boardDrawer_testbench/Reset
add wave -noupdate /boardDrawer_testbench/enable
add wave -noupdate /boardDrawer_testbench/blackNotWhite
add wave -noupdate /boardDrawer_testbench/doneBit
add wave -noupdate -radix unsigned /boardDrawer_testbench/x
add wave -noupdate -radix unsigned /boardDrawer_testbench/y
add wave -noupdate -expand -group intenrals -radix unsigned /boardDrawer_testbench/dut/x
add wave -noupdate -expand -group intenrals -radix unsigned /boardDrawer_testbench/dut/y
add wave -noupdate -expand -group intenrals -radix unsigned /boardDrawer_testbench/dut/xCounter
add wave -noupdate -expand -group intenrals -radix unsigned /boardDrawer_testbench/dut/nextXCounter
add wave -noupdate -expand -group intenrals -radix unsigned /boardDrawer_testbench/dut/nextY
add wave -noupdate -expand -group intenrals /boardDrawer_testbench/dut/ps
add wave -noupdate -expand -group intenrals /boardDrawer_testbench/dut/ns
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14381 ps} 0}
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
WaveRestoreZoom {13217 ps} {14649 ps}
