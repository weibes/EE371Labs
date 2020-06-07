module keyboardInput (Clock, Reset, motion, motion_enable, PS2_DAT, PS2_CLK);
	input logic Clock, Reset, PS2_DAT, PS2_CLK;
	output logic [1:0] motion;
	output logic motion_enable;
	
	logic valid, makeBreak, makeBreakStable;
	logic [7:0] outCode, outCodeStable;

	keyboard_press_driver keyboard (.CLOCK_50(Clock), .reset(Reset), .valid, .makeBreak, .outCode, 
											  .PS2_DAT, .PS2_CLK);
	
	always_ff @(posedge Clock) begin
		if (Reset) begin
			outCodeStable <= 0;
			makeBreakStable <= 0;
		end // if (reset) begin
		if (valid) begin
			outCodeStable <= outCode;
			makeBreakStable <= makeBreak;
		end // if (valid) begin
	end // always_ff @(posedge Clock) begin

	assign motion_enable = (valid && makeBreakStable && 
		((outCodeStable == 8'h74) || (outCodeStable == 8'h6b) || (outCodeStable == 8'h75) || (outCodeStable == 8'h72)));
		
	always_comb begin
		if (outCodeStable == 8'h74)
			motion = 2'b00;
		else if (outCodeStable == 8'h6b)
			motion = 2'b01;
		else if (outCodeStable == 8'h75)
			motion = 2'b10;
		else if (outCodeStable == 8'h72)
			motion = 2'b11;
		else 
			motion = 2'b00;
	end // always_comb begin
	
endmodule // module keyboardInput