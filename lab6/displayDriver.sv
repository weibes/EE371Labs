/* module displayDriver handles all of the graphics of the game, displaying the current play field data and where pieces are
 * currently located for the player to view and react to.
 * inputs: 
 *	dataIn is the data from the game logic RAM that gives data on the current row of blocks being read
 * Clock is the clock
 * REset is the reset
 * outputs:
 * rdaddress is the addres to the game logic RAM that reads a row of the game board, and where to draw pieces
 * VGA_R, VGA_G, VGA_B, VGA_BLANK_n, VGA_CLK, VGA_HS, VGA_SYNC_n, VGA_VS are all output data to go to the VGA display
 */

`timescale 1 ps / 1 ps
module displayDriver(dataIn, rdaddress, Clock, Reset,  VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);
	input logic [11:0] dataIn;
	input logic Clock, Reset;
	
	output logic [4:0] rdaddress;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_n;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_n;
	output VGA_VS;
	
//	output logic [9:0] xDebug;
	
//	// debug counter:
//	logic [24:0] cnt;
//	always_ff @(posedge clock) begin
//		if (Reset)
//			cnt <= 0;
//		else
//			cnt <= cnt + 1;
//	end // always_ff
//	
//	//debug Clock TODO rename input clock back to normal, on input name, in fctn, and in DE1_SoC file
//	logic Clock;
//	assign Clock = cnt[15];
//	
	
	logic [9:0] x, nextX, xBoard, xBlocks;
	logic [8:0] y, nextY, yBoard, yBlocks;
	logic boardDone, BNWBoard, BNWBlocks, pixel_color, next_pixel_color;
	
	enum {draw_board, draw_blocks} ps, ns;
	
	always_comb begin
		case (ps)
			draw_board:	begin
				if (boardDone)
					ns = draw_blocks;
				else
					ns = draw_board;
			end // draw_board: begin
			draw_blocks: begin
				ns = draw_blocks;	
			end // game_play: begin	
		endcase
	end // always_comb begin
	
	always_ff @(posedge Clock) begin
		if (Reset)
			ps <= draw_board;
		else
			ps <= ns;
	end // always_ff @(posedge Clock) begin
	
	
	
	// game board drawing submodule
	boardDrawer board (.Clock, .Reset, .enable(ps == draw_board), .x(xBoard), .yFinal(yBoard), .blackNotWhite(BNWBoard), .doneBit(boardDone));
	
	blockDrawer blocks (.Clock, .Reset, .enable(ps == draw_blocks), .rdaddress, .dataIn, .x(xBlocks), .yFinal(yBlocks), .blackNotWhite(BNWBlocks));
	
	
	// set RGB value to white or black, depending on output bit of board/block drawers
	always_comb begin
		// initialized vals 
		next_pixel_color = pixel_color; // assuming 0 is black, fix if not
		nextX = x;
		nextY = y;
		if (ps == draw_board) begin
			nextX = xBoard;
			nextY = yBoard;
			next_pixel_color = ~BNWBoard;
		end // if (ps == draw_board) begin
		else if (ps == draw_blocks) begin
			// debug
//			nextX = 0;
//			nextY = 0;
//			next_pixel_color = 0;

			nextX = xBlocks;
			nextY = yBlocks;
			next_pixel_color = ~BNWBlocks;
		end // else if (ps == draw_blocks) begin
	end // always_comb begin
	
	always_ff @(posedge Clock) begin
		if (Reset) begin
			x <= 0;
			y <= 0;
			pixel_color <= 0;
		end // if (Reset) begin
		else begin
			x <= nextX;
			y <= nextY;
			pixel_color <= next_pixel_color;
		end // else begin
	end // always_ff @(posedge Clock) begin
	
	VGA_framebuffer VGABuffer (.clk50(Clock), .reset(Reset), 
	.x({1'b0, x}),
	.y({2'b00, y}),
	.pixel_color, .pixel_write(1'b1),
	.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS, .VGA_BLANK_n, .VGA_SYNC_n);
	
	
	
	//assign xDebug = x;
	
endmodule // module displayDriver


module displayDriver_testbench();

	logic [11:0] dataIn;
	logic Clock, Reset;
	
	//logic [9:0] xDebug;
	
	logic [4:0] rdaddress;
	logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	logic VGA_BLANK_n;
	logic VGA_CLK;
	logic VGA_HS;
	logic VGA_SYNC_n;
	logic VGA_VS;
	
		// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
	end // initial begin
	
	displayDriver dut (.*);
	
	integer i;
	initial begin
		Reset = 1;										@(posedge Clock);
		Reset = 0;	dataIn = 12'b010010010010;	@(posedge Clock);
			for (i = 0; i < 500000; i++) begin
				@(posedge Clock);
				//assert(~((rdaddress != 0) && (xDebug == 272))) else $fatal(1, "drew to x=272 at %d", $time());
			end // for (i = 0; i < 100000; i++) begin
		
		$stop;
	end // initial begin
	
endmodule // module displayDriver_testbench


