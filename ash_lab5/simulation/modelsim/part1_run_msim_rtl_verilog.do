transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/AshEE371/lab5/lab5_staterkit {C:/AshEE371/lab5/lab5_staterkit/delay_adder.sv}

