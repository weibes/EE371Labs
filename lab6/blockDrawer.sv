`timescale 1 ps / 1 ps
module blockDrawer(Clock, Reset, enable, rdaddress, dataIn, blackNotWhite, x, y);
	input logic Clock, Reset, enable;
	input logic [9:0] dataIn;
	
	output logic [5:0] rdaddress;
	output logic blackNotWhite;
	output logic [9:0] x;
	output logic [8:0] y;
	
	logic nextBlackNotWhite;
	logic [9:0] nextX, nextNextX;
	logic [8:0] nextY, nextNextY;
	logic [10:0] array [10:0];
	
	// give coordinates of grid of blocks visible to player
	logic [3:0] xBlockCoord, nextXBlockCoord;
	logic [5:0] yBlockCoord, nextYBlockCoord;
	
	// for RAM usage
	assign rdaddress = yBlockCoord;
	
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
					if (yInternal == 4'd9) begin
						if (nextYBlockCoord == 0) 
							ns = readMem;
						else
							ns = loop;
					end // if (yInternal == 4'd11) begin
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
					if (yInternal == 4'd9) begin
						if (nextYBlockCoord == 0)
							ns = readMem;
						else
							ns = loop;
					end // if (yInternal == 4'd11) begin
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
			nextXBlockCoord = 0;
			nextYBlockCoord = 0;
		end // if (ps == ready && ns == readMem) begin
		
		//intCoords
		else if (ps == loop && (ns == draw || ns == erase)) begin
			nextXInternal = 0;
			nextYInternal = 0;
		end // else if (ps == loop && (ns == draw || ns == erase)) begin
		
		// updateCoords
		else if (ps == draw || ps == erase) begin
			nextNextX = (12 * xBlockCoord) + 261 + xInternal;
			nextNextY = (12 * yBlockCoord) + 1 + yInternal;
		end // else if (ps == draw || ps == erase) begin
		
		// blackNotWhite output
		if (ps == loop && ns == erase) 
			nextBlackNotWhite = 1'b1;
		else if (ps == draw) 
			nextBlackNotWhite = array[xInternal][yInternal];
		
		// incrBlockCoords
		if ((ps == draw || ps == erase) && (ns == loop || ns == readMem)) begin
			if (xBlockCoord == 4'd9) begin
				nextXBlockCoord = 0;
				if (yBlockCoord == 6'd39)
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
			xBlockCoord <= 0;
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
	logic [9:0] dataIn;
	logic blackNotWhite;
	logic [5:0] rdaddress;
	logic [9:0] x;
	logic [8:0] y;
	
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
		dataIn = 19'b1001000001;	@(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		@(posedge Clock); @(posedge Clock);
		
		$stop;
	end // initial begin

endmodule // blockDrawer_testbench