module delay_adder(Clock, enable, D, Q, Q_Div);

	input logic Clock, enable;
	input logic signed [23:0] D;
	output logic signed [23:0] Q, Q_Div;
	
	
	always_comb 
		Q_Div = Q / 8;
	
	always_ff @(posedge Clock) begin
		if(enable)
			Q <= D;
	end
endmodule 


module delay_adder_testbench();

	logic Clock, enable;
	logic signed [23:0] D;
	logic signed [23:0] Q, Q_Div;	
	
	delay_adder dut(.*);
	
	parameter CLOCK_PERIOD=50;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
	end // initial
		
	initial begin
		// checks whether inputs numbers and divides correctly.
		
		// checks for a positve set of number
		enable <= 1'b0;					               	@(posedge Clock);
		D <= 24'b000000000000000010000000;              @(posedge Clock);
		enable <= 1'b1;						               @(posedge Clock);            
		enable <= 1'b0;					                	@(posedge Clock);
		
		// checks division with another set of negative number
		D <= 24'b111111111111111111111111;              @(posedge Clock);
		enable <= 1'b1;						               @(posedge Clock);  
		enable <= 1'b0;						               @(posedge Clock);
					                  	                	@(posedge Clock);	
					                  	               	@(posedge Clock);	
		$stop;
		end
		
endmodule
		
		
	
