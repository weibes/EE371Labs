/* A decoder_4_to_16 module is used within the playfield module to decode a 4 to 16 bit
 * number within the collision detection FSM that is being asserted within the playfield.
 *
 * Inputs:
 * 	in - a 4 bit input for the decoder that represents the coordinate locations being written using the RAM.
 *
 * Outputs:
 * 	out - the 16 bit output from the decoder that represents the RAM data signals of the game logic.
 */
module decoder_4_to_16(in, out);
	input logic [3:0] in;
	output logic [0:15] out;
	
	always_comb begin
	integer i;
		for(i = 0; i < 16; i++) begin
			out[i] = (in == i);
		end
	end //always_comb
	
endmodule // decoder_4_to_16

