module playfield(Clock, reset, motion_enable, motion, address_b, 
						rden_b, q_b);
	input logic Clock, reset, motion_enable;
	input logic [1:0] motion;
	input logic [4:0] address_b;
	input logic rden_b; 
	output logic [11:0] q_b;
	
	logic [4:0] next_x, loc_x, next_y, loc_y, do_collision, no_collision;
	logic [4:0] piece[5:0];
	logic [4:0] next_piece[5:0];
	logic [3:0] decode_in;
	logic [0:15] decode_out;
	logic [1:0] counter, nextcounter;
	logic [23:0] create_counter, create_nextcounter;
	logic [4:0] address_a;
	logic [11:0] data_a, q_a, collide;
	logic rden_a, wren_a, down_request;
	logic piece_request, piece_ready;
	logic [4:0] block[5:0];
	
	logic piece_is_moving;
	
	
	assign collide = ((q_a & decode_out[0:11]) > 12'b0);
	
	
	
	pof_RAM storage(.address_a, .address_b, .clock(Clock), .data_a, .data_b(11'b0), 
						 .rden_a, .rden_b, .wren_a, .wren_b(1'b0), .q_a, .q_b);
	decoder_4_to_16 decode(.in(decode_in), .out(decode_out));
	piece_generate pieces (.Clock, .reset, .request(piece_request), .arr_out(piece), .data_ready(piece_ready));
	
	// the internal FSM for controlling the playfield.
	enum {waiting, down, left, right, cw, ccw} ps, ns;
	always_comb begin
	integer i;
	// default:
	next_x = loc_x;
	next_y = loc_y;
	do_collision = 1'b0;
	next_piece = block;
		case(ps) 
			waiting: begin
			if(piece_ready)
				next_piece = piece;
			if(down_request) 
				ns = down;
			else begin
				if(motion_enable) 
				begin
					if(motion == 2'b00) 
						ns = left;
					else if(motion == 2'b01) 
						ns = right;
					else if(motion == 2'b10) 
						ns = ccw;
					else 
						ns = cw;
				end
				else
					ns = waiting;
				end
			end
			down:
			begin
				if(piece_ready)
					next_piece = piece;	
					
				next_y = loc_y + 5'b00001;	
				do_collision = 5'b00001;
				ns = waiting;	
			end
			left:
			begin
				if(piece_ready)
					next_piece = piece;	
					
				next_x = loc_x - 5'b00001;
				do_collision = 5'b00001;
				ns = waiting;
			end
			right:
			begin
				if(piece_ready)
					next_piece = piece;	
					
				next_x = loc_x + 1'b1;
				do_collision = 1'b1;
				ns = waiting;
			end
			cw:
			begin
				if(piece_ready) begin
					next_piece[5:3] = piece[2:0];
					for (i = 0; i < 3; i++) begin
						next_piece[i] = - piece[i + 3];				
					end
					do_collision = 1'b1;
					ns = waiting;
				end else begin
					next_piece[5:3] = block[2:0];
					for (i = 0; i < 3; i++) begin
						next_piece[i] = - block[i + 3];				
					end
					do_collision = 1'b1;
					ns = waiting;		
				end
			end
			ccw: 
			begin
				if(piece_ready) begin
					next_piece[2:0] = piece[5:3];
					for (i = 0; i < 3; i++) begin
						next_piece[i + 3] = - piece[i];				
					end
					do_collision = 1'b1;
					ns = waiting;
				end else begin
					next_piece[2:0] = block[5:3];
					for (i = 0; i < 3; i++) begin
						next_piece[i + 3] = - block[i];				
					end
					do_collision = 1'b1;
					ns = waiting;			
				end
			end
		endcase
	end
	
	always_ff @(posedge Clock) begin
		if(reset)
			ps <= waiting;
		else begin
			ps <= ns;
			if(no_collision)
				block <= next_piece;
			else
				block <= block;
		end
	end
	
	// piece_is_moving detects when a piece is moving, for logic for piece moving graphically
	assign piece_is_moving = (ps == down);
	
	
	// FSM for detecting collisions and moving the pieces
	enum {waiting_col, clear0, clear1, clear2, clear3, 
			check0, check1, check2, check3, write0, write1, write2, write3} ps_col, ns_col;
	
	always_comb begin
	//default:
		address_a = 5'bX;
		data_a = 12'b0;
		decode_in = 4'b0;
		wren_a = 1'b0;
		rden_a = 1'b1;
			case(ps_col) 
				waiting_col:
				begin
					nextcounter = 2'b00;
					if(do_collision)
						ns_col = clear0;
					else ns_col = waiting_col;		
				end
				clear0: 
				begin
					address_a = loc_y;
					decode_in = loc_x[3:0];
					data_a = (decode_out[0:11] ^ q_a); 
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b10) begin
						rden_a = 1'b0;
						wren_a = 1'b1;
						ns_col = clear1;
					end
					else
						ns_col = clear0;
				end
				clear1:
				begin
					address_a = loc_y + piece[3];
					decode_in = loc_x[3:0] + piece[0][3:0];
					data_a = (decode_out[0:11] ^ q_a); 
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b10) begin
						rden_a = 1'b0;
						wren_a = 1'b1;
						ns_col = clear2;
					end
					else
						ns_col = clear1;	
				end
				clear2:
				begin
					address_a = loc_y + piece[4];
					decode_in = loc_x[3:0] + piece[1][3:0];
					data_a = (decode_out[0:11] ^ q_a); 
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b10) begin
						rden_a = 1'b0;
						wren_a = 1'b1;
						ns_col = clear3;
					end
					else
						ns_col = clear2;	
				end
				clear3:
				begin
					address_a = loc_y + piece[5];
					decode_in = loc_x[3:0] + piece[2][3:0];
					data_a = (decode_out[0:11] ^ q_a); 
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b10) begin
						rden_a = 1'b0;
						wren_a = 1'b1;
						ns_col = check0;
					end
					else
						ns_col = clear3;	
				end
				check0: 
				begin
					address_a = next_y;
					decode_in = next_x[3:0];
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b10) begin				
						if(collide)
							ns_col = write0;
						else 
							ns_col = check1;
					end
					else
						ns_col = check0;
				end
				check1:
				begin
					address_a = next_y + next_piece[3];
					decode_in = next_x[3:0] + next_piece[0][3:0];
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b10) begin				
						if(collide)
							ns_col = write0;
						else 
							ns_col = check2;
					end
					else
						ns_col = check1;	
				end
				check2:		
				begin
					address_a = next_y + next_piece[4];
					decode_in = next_x[3:0] + next_piece[1][3:0];
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b10) begin				
						if(collide)
							ns_col = write0;
						else 
							ns_col = check3;
					end
					else
						ns_col = check2;
				end
				check3:
				begin
					address_a = next_y + next_piece[5];
					decode_in = next_x[3:0] + next_piece[2][3:0];
					if(counter == 2'b11)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b11) 
						ns_col = write0;	
					else
						ns_col = check3;
				end
				write0:
				begin
					address_a = loc_y;
					decode_in = loc_x[3:0];
					data_a = (decode_out[0:11] || q_a); 
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b10) begin
						rden_a = 1'b0;
						wren_a = 1'b1;
						ns_col = write1;
					end
					else
						ns_col = write0;	
				end
				write1:
				begin
					address_a = loc_y + piece[3];
					decode_in = loc_x[3:0] + piece[0][3:0];
					data_a = (decode_out[0:11] || q_a);
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;	
					if(counter == 2'b10) begin
						rden_a = 1'b0;
						wren_a = 1'b1;
						ns_col = write2;
					end
					else
						ns_col = write1;	
				end
				write2:
				begin
					address_a = loc_y + piece[4];
					decode_in = loc_x[3:0] + piece[1][3:0];
					data_a = (decode_out[0:11] || q_a); 
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b10) begin
						rden_a = 1'b0;
						wren_a = 1'b1;
						ns_col = write3;
					end
					else
						ns_col = write2;	
				end
				write3:
				begin
					address_a = loc_y + piece[5];
					decode_in = loc_x[3:0] + piece[2][3:0];
					data_a = (decode_out[0:11] || q_a); 
					if(counter == 2'b10)
						nextcounter = 2'b00;
					else 
						nextcounter = counter + 2'b01;
					if(counter == 2'b10) begin
						rden_a = 1'b0;
						wren_a = 1'b1;
						ns_col = waiting_col;
					end
					else
						ns_col = write3;	
				end
		endcase
	end
	
	always_ff @(posedge Clock) begin
		if(reset) begin
			ps_col <= waiting_col;
			counter <= 2'b00;
			no_collision = 1'b1;
		end
		else begin
			ps_col <= ns_col;
			counter <= nextcounter;
			if((ps_col == check0) || (ps_col == check1) || (ps_col == check2)
		   	|| (ps_col == check3)) begin
				if(counter == 2'b10) 
					no_collision <= no_collision && ~collide;
				else
					no_collision <= no_collision;
			end
			else if(ps_col == clear0)
				no_collision <= 1'b1;
			else
				no_collision <= no_collision;
		end
	end
	
	// FSM for creating and moving the pieces on the screen
	enum {create, waiting_create, moving_down_delay, move_down} ps_create, ns_create;
	always_comb begin
	// default:
	piece_request = 1'b0;
	down_request = 1'b0;
	create_nextcounter = create_counter;
		case(ps_create) 
			create:
				begin
				piece_request = 1'b1;
				if(piece_ready)
					ns_create = move_down;
				else
					ns_create = create;
				end
			waiting_create:
				begin
				if (ns_col == waiting_col)
					ns_create = create;
				else begin
					if(piece_is_moving)
						ns_create = moving_down_delay;
					else
						ns_create = waiting_create; 				
				end
				end
			moving_down_delay:
				begin
				create_nextcounter = create_counter + 24'b000000000000000000001;
				// debug line, remove for actual
				//if(create_counter == 24'b0)
				if (create_counter == 24'h000005)
					ns_create = move_down;	
				else
					ns_create = moving_down_delay;
				end
			move_down:
				begin
				create_nextcounter = 1;
				down_request = 1'b1;
				if((ps_col == waiting_col) && (no_collision == 1'b1))
					ns_create = waiting_create;
				else
					ns_create = move_down;
				end
		endcase
	end
	
	always_ff @(posedge Clock) begin
		if(reset) begin
			ps_create <= create;
			create_counter <= 24'b0;
			loc_x <= 0;
			loc_y <= 0;
		end
		else begin
			ps_create <= ns_create;
			loc_x <= next_x;
			loc_y <= next_y;
			create_counter <= create_nextcounter;
		end
	end
endmodule

`timescale 1 ps / 1 ps
module playfield_testbench();

	logic Clock, reset, motion_enable;
	logic [1:0] motion;
	logic [4:0] address_b;
	logic rden_b; 
	logic [11:0] q_b;

	parameter CLOCK_PERIOD=100;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
	end // initial begin
	
	playfield dut (.*);
	
	integer i, addressRead;
	initial begin
		addressRead = 0;
		reset = 1;	rden_b = 1;	motion = 2'b00;	@(posedge Clock);
		reset = 0;	motion_enable = 0;				@(posedge Clock);
		for (i = 0; i < 1000; i++) begin
			@(posedge Clock);
			if (addressRead == 19)
				addressRead = 0;
			else
				addressRead++;
			address_b = addressRead;
		end
		$stop;
	end // initial begin
	
endmodule // module playfield_testbench()