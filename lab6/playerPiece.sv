/* playerPiece controls the piece the player is currently moving on the screen
	inputs: 
	clock is clock
	reset is reset
	normalCollisionDetected says whether or not the previous move was a collision, but the piece can still be moved
	endCollisionDetected says if the previous move was a collision and a new piece should generate
	collisionReady states whether or not the collision detection has finished 
	motion_enable is when theres a new keyboard input from the player
	motion determiens what type of input was given:
		00: move right
		01: move left
		10: CW rotation
		11: CCW rotation
		
	outputs:
	pieceOriginX is the X coord. origin of the piece for putting into the screen RAM
	pieceOriginY is the Y coord. origin of the piece for putting into the screen RAM
	pieceOffsets is the offsets for the remaining blocks for the block currently being displayed
	pieceOFfsets has the form: {x1, x2, x3, y1, y2, y3}.
*/

module playerPiece(Clock, reset, normalCollisionDetected, endCollisionDetected, collisionReady, collisionRequest, 
						 pieceOriginX, pieceOriginY, pieceOffsets, motion_enable, motion);
	
	input logic Clock, reset, normalCollisionDetected, endCollisionDetected,
					collisionReady, motion_enable;
	input logic [1:0] motion;
	output logic [4:0] pieceOriginX, pieceOriginY;
	output logic [5:0] pieceOffsets;
	output logic collisionRequest;
	
	
	logic [2:0] currPiece, nextPiece, generatedPiece;
	logic [1:0] rotation, nextRotation, prevRotation;
	
	logic [4:0] prevPieceOriginX, prevPieceOriginY, nextPieceOriginX, nextPieceOriginY;
	logic [5:0] prevPieceOffsets, nextPieceOffsets, generatedPieceOffsets;
	logic [22:0] downCount, nextDownCount;
	
	LFSR10 numGen (.Clock, .reset, .Q_out(generatedPiece));
	
	PieceROM ROM (.address({nextPiece, rotation}), .clock(Clock), .q(generatedPieceOffsets));
	
	enum {genPiece, readOffsets, waitMovement, readRotation, waitCollision} ps, ns;
	
	always_comb begin
		nextPiece = currPiece;
		nextPieceOffsets = pieceOffsets;
		nextDownCount = downCount;
		nextRotation = rotation;
		nextPieceOriginX = pieceOriginX;
		nextPieceOriginY = pieceOriginY;
		collisionRequest = 1'b0;
		case(ps)
			genPiece: begin
				if (generatedPiece == 3'b111)
					nextPiece = 3'b100;
				else
					nextPiece = generatedPiece;
				nextPieceOriginX = 5;
				nextPieceOriginY = 2;
				ns = readOffsets;
				nextRotation = 2'b00;
			end // genPiece: begin
			readOffsets: begin
				ns = waitMovement;
				nextPieceOffsets = generatedPieceOffsets;
			end // readOffsets: begin
			waitMovement: begin
				if (motion_enable) begin
					case(motion)
						2'b00: begin
							nextPieceOriginX = pieceOriginX + 1'b1;
							ns = waitCollision;
						end
						2'b01: begin
							nextPieceOriginX = pieceOriginX - 1'b1;
							ns = waitCollision;
						end
						2'b10: begin
							nextRotation = rotation + 1'b1;
							ns = readRotation;
						end
						2'b11: begin
							nextRotation = rotation - 1'b1;
							ns = readRotation;
						end
					endcase
				end // if (motion_enable) begin
				else begin
					if (downCount[22]) begin
						nextDownCount = 0;
						nextPieceOriginY = pieceOriginY + 1'b1;
						ns = waitCollision;
					end // if (downCount[24]) begin
					else begin
						nextDownCount = downCount + 1'b1;
						ns = waitMovement;
					end // else begin
				end // else begin
			end // waitMovement: begin
			readRotation: begin
				ns = waitCollision;
				nextPieceOffsets = generatedPieceOffsets;
			end // readRotation: begin
			waitCollision: begin
				collisionRequest = 1'b1;
				if (collisionReady) begin
					if (endCollisionDetected)
						ns = genPiece;
					else begin
						ns = waitMovement;
						if (normalCollisionDetected) begin
							nextPieceOriginX = prevPieceOriginX;
							nextPieceOriginY = prevPieceOriginY;
							nextPieceOffsets = prevPieceOffsets;
							nextRotation = prevRotation;
						end // if (normalCollisionDetected) begin
					end // else begin
				end // if (collisionReady) begin
				else
					ns = waitCollision;
			end // waitCollision: begin
		endcase
	end // always_comb begin
	
	
	
	always_ff @(posedge Clock) begin
		if (reset) begin
			ps <= genPiece;
			pieceOriginX = 5;
			pieceOriginY = 2;
			currPiece <= 0;
			downCount <= 0;
			rotation <= 0;
		end // if (reset) begin
		else begin
			ps <= ns;
			pieceOriginX <= nextPieceOriginX;
			pieceOriginY <= nextPieceOriginY;
			pieceOffsets <= nextPieceOffsets;
			currPiece <= nextPiece;
			downCount <= nextDownCount;
			rotation <= nextRotation;
			if (ps == waitMovement) begin
				prevPieceOriginX <= pieceOriginX;
				prevPieceOriginY <= pieceOriginY;
				prevRotation <= rotation;
				prevPieceOffsets <= pieceOffsets;
			end // if (ps == waitMovement) begin
		end // else begin
	
	end // always_ff @(posedge Clock) begein
	
	
endmodule // module playerPiece

module playerPiece_testbench();
	logic Clock, reset, normalCollisionDetected, endCollisionDetected,
					collisionReady, motion_enable;
	logic [1:0] motion;
	logic [4:0] pieceOriginX, pieceOriginY;
	logic [5:0] pieceOffsets;
	
	// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
	end // initial begin
	
	playerPiece dut (.*);
	
	integer randNum, i;
	initial begin
		reset = 1'b1;						@(posedge Clock);
		reset = 1'b0;						@(posedge Clock);
		$srandom(12);
		randNum = $urandom_range(20, 30);
		for (i = 0; i < randNum; i++) begin
			@(posedge Clock);
		end 
		
		$stop;
	end // initial begin
	

endmodule

