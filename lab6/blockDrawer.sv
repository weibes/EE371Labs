/* module blockDrawer draws the blocks from the game logic RAM onto the current playfield
 * for the player to see where the pieces are currently located
 * inputs:
 * Clock is the clock
 * Reset is a reset
 * enable is from the graphics controller stating when the blockDrawer can start drawing blocks
 * dataIn is the data from the game logic RAM that gives one row of block data
 * outputs:
 * rdaddress is the address in the gamelogic RAM to read from (which represents each row of the playfield)
 * blackNotWhite tells the VGA driver if it should draw a black or white pixel
 * x tells the VGA driver what x coordinate to draw to on the 480x640 monitor
 * yFinal tells the VGA driver what y coordinate to draw to on the 480x640 monitor
 */
`timescale 1 ps / 1 ps
module blockDrawer(Clock, Reset, enable, rdaddress, dataIn, blackNotWhite, x, yFinal);
	input logic Clock, Reset, enable;
	input logic [11:0] dataIn;
	
	output logic [4:0] rdaddress;
	output logic blackNotWhite;
	output logic [9:0] x;
	output logic [8:0] yFinal;
	
	logic nextBlackNotWhite;
	logic [9:0] nextX, nextNextX;
	logic [8:0] y, nextY, nextNextY;
	logic [10:0] array [10:0];
	
	// give coordinates of grid of blocks visible to player
	logic [3:0] xBlockCoord, nextXBlockCoord;
	logic [4:0] yBlockCoord, nextYBlockCoord;
	
	// for RAM usage
	assign rdaddress = yBlockCoord;
	
	// for changing printing location
	assign yFinal = y + 120; 
	
	// give coordinates of pixels inside of each block to be drawn
	logic [3:0] xInternal, yInternal, nextXInternal, nextYInternal;
	
	
	enum {ready, loop, draw, erase, readMem} ps, ns;
	
	always_comb begin
		nextXBlockCoord = xBlockCoord;
		nextYBlockCoord = yBlockCoord;
		nextXInternal = xInternal;
		nextYInternal = yInternal;
		nextNextX = nextX;
		nextNextY = nextY;
		nextBlackNotWhite = 1'b1;
		
		case(ps) 
			ready: begin
				if (enable)
					ns = readMem;
				else
					ns = ready;
			end // ready: begin
			loop: begin
				if (dataIn[xBlockCoord])
					ns = draw;
				else 
					ns = erase;
			end // loop: begin
			draw: begin
				if (xInternal == 4'd9) begin
					nextXInternal = 0;
					if (yInternal == 4'd9)
						ns = readMem;
					else begin
						ns = draw;
						nextYInternal = yInternal + 1'b1;
					end // else begin
				end // if (xInternal == 4'd11) begin
				else begin 
					ns = draw;
					nextXInternal = xInternal + 1;
				end // else begin
			end // draw: begin
			erase: begin
				if (xInternal == 4'd9) begin
					nextXInternal = 0;
					if (yInternal == 4'd9)
						ns = readMem;
					else begin
						ns = erase;
						nextYInternal = yInternal + 1'b1;
					end // else begin
				end // if (xInternal == 4'd11) begin
				else begin 
					ns = erase;
					nextXInternal = xInternal + 1;
				end // else begin
			end // erase: begin
			readMem:
				ns = loop;


		endcase // case(ps)
		
		// datapath outputs
		// initializeOffset
		if (ps == ready && ns == readMem) begin
			nextXBlockCoord = 1;
			nextYBlockCoord = 0;
		end // if (ps == ready && ns == readMem) begin
		
		//intCoords
		else if (ps == loop && (ns == draw || ns == erase)) begin
			nextXInternal = 0;
			nextYInternal = 0;
		end // else if (ps == loop && (ns == draw || ns == erase)) begin
		
		// updateCoords
		else if (ps == draw || ps == erase) begin
			nextNextX = (12 * xBlockCoord) + 249 + xInternal;
			nextNextY = (12 * yBlockCoord) + 1 + yInternal;
		end // else if (ps == draw || ps == erase) begin
		
		// blackNotWhite output
		if (ps == loop && ns == erase) 
			nextBlackNotWhite = 1'b1;
		else if (ps == draw) 
			nextBlackNotWhite = array[xInternal][yInternal];
		
		// incrBlockCoords
		if ((ps == draw || ps == erase) && (ns == loop || ns == readMem)) begin
			if (xBlockCoord == 4'd10) begin
				nextXBlockCoord = 1;
				if (yBlockCoord == 6'd19)
					nextYBlockCoord = 0;
				else 
					nextYBlockCoord = yBlockCoord + 1'b1;
			end // if (xBlockCoord == 4'd9) begin
			else
				nextXBlockCoord = xBlockCoord + 1'b1;
		end // if ((ps == draw || ps == erase) && (ns == loop) begin
		
	end // always_comb begin
	
	always_ff @(posedge Clock) begin
		if (Reset) begin
			ps <= ready;
			xBlockCoord <= 1;
			yBlockCoord <= 0;
			xInternal <= 0;
			yInternal <= 0;
			x <= 0;
			y <= 0;
			nextX <= 0;
			nextY <= 0;
			blackNotWhite <= 1;
		end // if (Reset) begin
		else begin
			ps <= ns;
			xBlockCoord <= nextXBlockCoord;
			yBlockCoord <= nextYBlockCoord;
			xInternal <= nextXInternal;
			yInternal <= nextYInternal;
			x <= nextX;
			nextX <= nextNextX;
			y <= nextY;
			nextY <= nextNextY;
			blackNotWhite <= nextBlackNotWhite;
		end // else begin
	end // always_ff @(posedge Clock) begin
	
	// data for pixel drawing of block
	always_comb begin
		array[0] =  { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 };
		array[1] =  { 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 };
		array[2] =  { 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 };
		array[3] =  { 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1 };
		array[4] =  { 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1 };
		array[5] =  { 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 };
		array[6] =  { 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1 };
		array[7] =  { 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1 };
		array[8] =  { 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1 };
		array[9] =  { 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 };
		array[10] =  { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1 };
	end // always_comb begin

	
endmodule // module blockDrawer

module blockDrawer_testbench();
	logic Clock, Reset, enable;
	logic [11:0] dataIn;
	logic blackNotWhite;
	logic [4:0] rdaddress;
	logic [9:0] x;
	logic [8:0] yFinal;
	
	// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
	end // initial begin
	
	blockDrawer dut (.*);
	
	initial begin
		Reset = 1'b1;	@(posedge Clock);
		Reset = 1'b0;	@(posedge Clock);
		enable = 1'b1;	@(posedge Clock);
		dataIn = 12'b010010000010;	@(posedge Clock);
		@(posedge rdaddress[0]);
		dataIn = 12'b001111100010; @(posedge Clock);
		@(negedge rdaddress[0]);
		dataIn = 12'b111111111000;	@(posedge Clock);
		@(posedge rdaddress[0]);
		
		$stop;
	end // initial begin

endmodule // blockDrawer_testbench