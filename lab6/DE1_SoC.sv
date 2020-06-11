/* Top level module of the FPGA that takes the onboard resources 
 * as input and outputs the lines drawn from the VGA port.
 *
 * Inputs:
 *   KEY 			- On board keys of the FPGA
 *   SW 			- On board switches of the FPGA
 *   CLOCK_50 		- On board 50 MHz clock of the FPGA
 *   CLOCK2_50  	- FPGA on board 2nd 50 MHz clock
 *   FPGA_I2C_SCLK 	- FPGA I2C communication protocol clock
 *   FPGA_I2C_SDAT  - FPGA I2C communication protocol data
 *   AUD_XCK 		- Audio CODEC data
 *   AUD_DACLRCK 	- Audio CODEC data
 *   AUD_ADCLRCK 	- Audio CODEC data
 *   AUD_BCLK 		- Audio CODEC data
 *   AUD_ADCDAT 	- Audio CODEC data

 * Outputs:
 *   HEX 			- On board 7 segment displays of the FPGA
 *   LEDR 			- On board LEDs of the FPGA
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 			- Blue data of the VGA connection
 *   VGA_BLANK_N 	- Blanking interval of the VGA connection
 *   VGA_CLK 		- VGA's clock signal
 *   VGA_HS 		- Horizontal Sync of the VGA connection
 *   VGA_SYNC_N 	- Enable signal for the sync of the VGA connection
 *   VGA_VS 		- Vertical Sync of the VGA connection
 *   AUD_DACDAT 	- output Audio CODEC data
 */

`timescale 1 ps / 1 ps
module DE1_SoC (KEY, SW, CLOCK_50, CLOCK2_50, PS2_DAT, PS2_CLK,
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS,
	FPGA_I2C_SCLK, 
	FPGA_I2C_SDAT, 
	AUD_XCK, 
	AUD_DACLRCK, 
	AUD_ADCLRCK, 
	AUD_BCLK, 
	AUD_ADCDAT, 
	AUD_DACDAT,
	HEX0, HEX1, LEDR);
	
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic CLOCK_50, CLOCK2_50;
	input logic PS2_DAT, PS2_CLK;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	output logic [6:0] HEX0, HEX1;
	output logic [9:0] LEDR;
	
	output logic FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	output logic AUD_XCK;
	input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input logic AUD_ADCDAT;
	output logic AUD_DACDAT;
	
	
	logic piece_ready, motion_enable, motion_enable_out, motion_enable_1, motion_enable_2, piece_request;
	logic [1:0] motion;
	logic [4:0] address_b;
	logic [11:0] q_b;
	
	
	playfield field (.Clock(CLOCK_50), .reset(~KEY[0]), .motion_enable(motion_enable_out), .motion, .address_b,
						  .rden_b(1'b1), .q_b);
	

	
	MusicPlayer music (.CLOCK_50, .CLOCK2_50, .FPGA_I2C_SCLK, .FPGA_I2C_SDAT, .AUD_XCK, .AUD_DACLRCK, .AUD_ADCLRCK, .AUD_BCLK,
						  .AUD_ADCDAT, .AUD_DACDAT, .reset(~KEY[0]), .MusicEnable(1'b1));

	// testRAM, for monitor debug only
	//GraphicsTestRAM gtr (.rdaddress(address_b), .wraddress(12'd0), .clock(CLOCK_50), .q(q_b), .wren(1'b1), .data({~KEY[3], SW, ~KEY[2]}));
	
	displayDriver display (.dataIn(q_b), .rdaddress(address_b), .Clock(CLOCK_50), .Reset(~KEY[0]),  .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS, 
	.VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));

	keyboardInput keyboard (.Clock(CLOCK_50), .Reset(~KEY[0]), .motion, .motion_enable, .PS2_DAT, .PS2_CLK);
	
	// instantiate the debugger for keyboard signals.
	seg7 displayTest (.bcd({2'b00, motion}), .leds(HEX0));
	
	// FSM for the motion enable on for 1 clock cycle
	always_comb begin
		motion_enable_out = motion_enable_1 &~ motion_enable_2;
	end
	
	logic [3:0] cnt;
	always_ff @(posedge CLOCK_50) begin
		motion_enable_1 <= motion_enable;
		motion_enable_2 <= motion_enable_1;
		if (~KEY[0])
			cnt <= 4'b0;
		else if (motion_enable)
			cnt <= cnt + 1'b1;
	end
	
	seg7 count (.bcd(cnt), .leds(HEX1));
	// deinstaniate and end debugger for keyboard signals.
	
endmodule // module DE1_SoC
