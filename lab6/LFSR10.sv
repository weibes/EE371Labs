module LFSR10 (Clock, reset, Q_out1, Q_out2);
	input logic Clock, reset;
	logic [9:0] Q;
	output logic [2:0] Q_out1; 
	output logic [1:0] Q_out2;
	
	assign Q_out1 = {Q[8], Q[4], Q[2]};
	assign Q_out2 = {Q[6], Q[3]};

	always_ff @(posedge Clock) begin
		if (reset) Q <= 0;
			else begin
				Q[9] <= Q[8];
				Q[8] <= Q[7];
				Q[7] <= Q[6];
				Q[6] <= Q[5];
				Q[5] <= Q[4];
				Q[4] <= Q[3];
				Q[3] <= Q[2];
				Q[2] <= Q[1];
				Q[1] <= Q[0];
				Q[0] <= (Q[6] ~^ Q[9]);
			end
	end
endmodule

module LFSR10_testbench();
	logic Clock, reset;
	logic [2:0] Q_out1; 
	logic [1:0] Q_out2;
	
	LFSR10 dut (.Clock, .reset, .Q_out1, .Q_out2);
	
	parameter CLOCK_PERIOD=50;
		initial begin
			Clock <= 0;
			forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
		end
		
	initial begin @(posedge Clock)
		reset <= 1; @(posedge Clock);
		reset <= 0;
		repeat (15) begin
			@(posedge Clock);
			@(posedge Clock);
			@(posedge Clock);
			@(posedge Clock);
			@(posedge Clock);
			@(posedge Clock);
			@(posedge Clock);
			@(posedge Clock);
		end
		$stop;
	end
endmodule
