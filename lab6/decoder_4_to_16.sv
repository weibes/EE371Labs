module decoder_4_to_16(in, out);
	input logic [3:0] in;
	output logic [0:15] out;
	
	always_comb begin
	integer i;
		for(i = 0; i < 16; i++) begin
			out[i] = (in == i);
		end
	end
	
endmodule
