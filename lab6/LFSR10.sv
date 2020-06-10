/* A LFSR10 module that is used to encode a 10 bit randomly generated values used to
 * randomly rotate the the tetris blocks that is being created by piece_generate module.
 *
 * Inputs:
 *   Clock - the synchronous clock signal.
 *   reset - the reset state for the FSMs and used to syncronyze with the clock.
 *
 * Outputs:
 * 	Q_out1 - this is a 3 bit number that is used to concatenate only 3 different bits of the 10 bit LFSR 
 *             random number generator.
 *					
 *    Q_out1 - this is a 2 bit number that is used to concatenate only 2 different bits of the 10 bit LFSR
 *             random number generator.
 */
module LFSR10 (Clock, reset, Q_out1, Q_out2);
	input logic Clock, reset;
	output logic [2:0] Q_out1; 
	output logic [1:0] Q_out2;
	
	logic [9:0] Q;
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
	end //always_ff
	
endmodule //LFSR10

/* testbench for the LFSR10 that tests the overall function of the module and outputs 
   produced given the varied inputs. Port connections *see LFSR10 module*. */
module LFSR10_testbench();
	logic Clock, reset;
	logic [2:0] Q_out1; 
	logic [1:0] Q_out2;
	
	LFSR10 dut (.Clock, .reset, .Q_out1, .Q_out2);
	
	parameter CLOCK_PERIOD=50;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
	end //initial
		
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
	end //initial
endmodule //LFSR10_testbench
