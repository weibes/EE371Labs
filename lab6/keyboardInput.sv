module keyboardInput (Clock, Reset, motion, PS2_DAT, PS2_CLK);
	input logic Clock, Reset, PS2_DAT, PS2_CLK;
	output logic [1:0] motion;

	
	logic valid, makeBreak;
	logic [7:0] outCode;

	keyboard_press_driver keyboard (.CLOCK_50(Clock), .reset(Reset), .valid, .makeBreak, .outCode, 
											  .PS2_DAT, .PS2_CLK);
											  
endmodule // module keyboardInput