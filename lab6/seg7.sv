/*
 *	module seg7 takes a valid 4 bit input and turns it into a number to be displayed
 * on a standard 7-segment HEX display
 * based on seg7 from EE 271, extended to represent hexidecimal numbers
 * I/O:
 *	in:
 *		bcd gives input number
 *	out:
 *		leds gives lights to light up or not, where 1 is low
*/
module seg7 (bcd, leds);
	input logic [3:0] bcd;
	output logic [6:0] leds;
	
	always_comb begin
		case (bcd)
			// Light: 			 6543210
			4'b0000: leds = 7'b1000000; // 0
			4'b0001: leds = 7'b1111001; // 1
			4'b0010: leds = 7'b0100100; // 2
			4'b0011: leds = 7'b0110000; // 3
			4'b0100: leds = 7'b0011001; // 4
			4'b0101: leds = 7'b0010010; // 5
			4'b0110: leds = 7'b0000010; // 6
			4'b0111: leds = 7'b1111000; // 7
			4'b1000: leds = 7'b0000000; // 8
			4'b1001: leds = 7'b0010000; // 9
			4'b1010: leds = 7'b0001000; // A
			4'b1011: leds = 7'b0000011; // b
			4'b1100: leds = 7'b1000110; // C
			4'b1101: leds = 7'b0100001; // d
			4'b1110: leds = 7'b0000110; // E
			4'b1111: leds = 7'b0001110; // F
		endcase //ends case statement
	end //ends always_comb block
/* ends seg7 module */
endmodule 
