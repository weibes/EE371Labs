`timescale 1 ps / 1 ps
module displayDriver(dataIn, rdaddress, Clock, Reset,  VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);
	input logic [9:0] dataIn;
	input logic Clock, Reset;
	
	output logic [5:0] rdaddress;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_n;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_n;
	output VGA_VS;
	
	logic [9:0] x, nextX, xBoard, xBlocks;
	logic [8:0] y, nextY, yBoard, yBlocks;
	logic boardDone, BNWBoard, BNWBlocks, pixel_color;
	
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
	boardDrawer board (.Clock, .Reset, .enable(ps == draw_board), .x(xBoard), .y(yBoard), .blackNotWhite(BNWBoard), .doneBit(boardDone));
	
	blockDrawer blocks (.Clock, .Reset, .enable(ps == draw_blocks), .rdaddress, .dataIn, .x(xBlocks), .y(yBlocks), .blackNotWhite(BNWBlocks));
	
	
	// set RGB value to white or black, depending on output bit of board/block drawers
	always_comb begin
		// initialized vals 
		pixel_color = 1'b0; // assuming 0 is black, fix if not
		nextX = x;
		nextY = y;
		if (ps == draw_board) begin
			nextX = xBoard;
			nextY = yBoard;
			pixel_color = ~BNWBoard;
		end // if (ps == draw_board) begin
		else if (ps == draw_blocks) begin
			nextX = xBlocks;
			nextY = yBlocks;
			pixel_color = ~BNWBlocks;
		end // else if (ps == draw_blocks) begin
	end // always_comb begin
	
	always_ff @(posedge Clock) begin
		if (Reset) begin
			x <= 0;
			y <= 0;
		end // if (Reset) begin
		else begin
			x <= nextX;
			y <= nextY;
		end // else begin
	end // always_ff @(posedge Clock) begin
	
	VGA_framebuffer VGABuffer (.clk50(Clock), .reset(Reset), 
	.x({1'b0, x}),
	.y({2'b00, y}),
	.pixel_color, .pixel_write(1'b1),
	.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS, .VGA_BLANK_n, .VGA_SYNC_n);
	
endmodule

