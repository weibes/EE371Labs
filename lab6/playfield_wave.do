onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /playfield_testbench/Clock
add wave -noupdate /playfield_testbench/reset
add wave -noupdate /playfield_testbench/motion_enable
add wave -noupdate /playfield_testbench/motion
add wave -noupdate /playfield_testbench/address_b
add wave -noupdate /playfield_testbench/rden_b
add wave -noupdate /playfield_testbench/q_b
add wave -noupdate -expand -group internals /playfield_testbench/dut/next_x
add wave -noupdate -expand -group internals /playfield_testbench/dut/loc_x
add wave -noupdate -expand -group internals /playfield_testbench/dut/next_y
add wave -noupdate -expand -group internals /playfield_testbench/dut/loc_y
add wave -noupdate -expand -group internals /playfield_testbench/dut/do_collision
add wave -noupdate -expand -group internals /playfield_testbench/dut/no_collision
add wave -noupdate -expand -group internals /playfield_testbench/dut/piece
add wave -noupdate -expand -group internals /playfield_testbench/dut/next_piece
add wave -noupdate -expand -group internals /playfield_testbench/dut/decode_in
add wave -noupdate -expand -group internals /playfield_testbench/dut/decode_out
add wave -noupdate -expand -group internals /playfield_testbench/dut/counter
add wave -noupdate -expand -group internals /playfield_testbench/dut/nextcounter
add wave -noupdate -expand -group internals /playfield_testbench/dut/create_counter
add wave -noupdate -expand -group internals /playfield_testbench/dut/create_nextcounter
add wave -noupdate -expand -group internals /playfield_testbench/dut/address_a
add wave -noupdate -expand -group internals /playfield_testbench/dut/data_a
add wave -noupdate -expand -group internals /playfield_testbench/dut/q_a
add wave -noupdate -expand -group internals /playfield_testbench/dut/collide
add wave -noupdate -expand -group internals /playfield_testbench/dut/rden_a
add wave -noupdate -expand -group internals /playfield_testbench/dut/wren_a
add wave -noupdate -expand -group internals /playfield_testbench/dut/down_request
add wave -noupdate -expand -group internals /playfield_testbench/dut/piece_request
add wave -noupdate -expand -group internals /playfield_testbench/dut/piece_ready
add wave -noupdate -expand -group internals /playfield_testbench/dut/block
add wave -noupdate -expand -group internals /playfield_testbench/dut/ps
add wave -noupdate -expand -group internals /playfield_testbench/dut/ns
add wave -noupdate -expand -group internals /playfield_testbench/dut/ps_col
add wave -noupdate -expand -group internals /playfield_testbench/dut/ns_col
add wave -noupdate -expand -group internals /playfield_testbench/dut/ps_create
add wave -noupdate -expand -group internals /playfield_testbench/dut/ns_create
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {57 ps} 0}
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
WaveRestoreZoom {2750 ps} {3750 ps}
