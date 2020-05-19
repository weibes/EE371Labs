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
		enable <= 1'b0;					               	@(posedge Clock);
		
		// checks division for a big positive number
		D <= 24'b000000000000000010000000;              @(posedge Clock);
		enable <= 1'b1;						               @(posedge Clock);            
		enable <= 1'b0;					                	@(posedge Clock);
		
		// checks division for a small positive number
		D <= 24'b000000000000000000001000;              @(posedge Clock);
		enable <= 1'b1;						               @(posedge Clock);            
		enable <= 1'b0;					                	@(posedge Clock);
		
		// checks division for a big negative number
		D <= 24'b111111111111111110000000;              @(posedge Clock);
		enable <= 1'b1;						               @(posedge Clock);  
		enable <= 1'b0;						               @(posedge Clock);
		
		// checks division for a small negative number
		D <= 24'b111111111111111111111000;              @(posedge Clock);
		enable <= 1'b1;						               @(posedge Clock);  
		enable <= 1'b0;						               @(posedge Clock);

		// checks division for a small positive number, giving 0 as ouput
		D <= 24'b000000000000000000000001;              @(posedge Clock);
		enable <= 1'b1;						               @(posedge Clock);            
		enable <= 1'b0;					                	@(posedge Clock);
		
		// checks division for a small negative number, giving 0 as output
		D <= 24'b111111111111111111111111;              @(posedge Clock);
		enable <= 1'b1;						               @(posedge Clock);  
		enable <= 1'b0;						               @(posedge Clock);
		
		// checks division for 0 as input number, giving a undefined as ouput
		D <= 24'b000000000000000000000000;              @(posedge Clock);
		enable <= 1'b1;						               @(posedge Clock);            
		enable <= 1'b0;					                	@(posedge Clock);
		
		repeat(6)      			                  	  	@(posedge Clock);	
					                  	               	@(posedge Clock);	
		$stop;
		end
		
endmodule
			
		
	
