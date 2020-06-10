/* A piece_generate module that generates the 5 different pieces of a tetris block
 * and stores it in array, which contains the coordinate system, which can be mapped
 * to create the actual blocks of the tetris on display.
 * 
 * Inputs:
 *   Clock - the synchronous clock signal.
 *   reset - the reset state for the FSMs and used to syncronyze with the clock.
 *   request - this is the signal that is coming from the playfield, which is asserted when the user
 *					requests a piece of tetris block.
 *
 * Outputs:
 * 	arr_out - this is the array that contains the coordinate dimensions of tetris blocks that can be mapped
 *					 to actually create those blocks on display.
 *    data_ready - this is the ready signal from the system that asserts when a block is ready to be display
 *                 after the proper operations like random rotations.
 */
module piece_generate(Clock, reset, request, arr_out, data_ready); 
	input logic Clock, reset, request;
	output logic [4:0] arr_out[5:0];
	output logic data_ready;
	
	// Declare logic statements and variables. Connect the internal ports
	// with respective input and output ports.
	logic [4:0] arr[5:0];
	logic [2:0] shape, read_addr;
	logic [1:0] rotate;
	logic do_xy, done_xy;
	logic [4:0] read, q, inc;
	
	// the read signal = 6 * read_addr + inc, used to feed into the ROM's address.
	assign read = {read_addr, 2'b0} + {1'b0, read_addr, 1'b0} + inc;
	
	// instantiate the random number generator that rotates the blocks everytime a block is ready
	// instantiates the ROM that outputs the array coordiates for each of the pieces that forms the tetris blocks.
	LFSR10 random(.Clock, .reset, .Q_out1(shape), .Q_out2(rotate));
	ROM rom(.address(read), .clock(Clock), .rden(1'b1), .q);
	
	// algorthmic design that chooses a random rotation for the blocks being generated. 
	always_comb begin
		integer i;
		case(rotate) 
			2'b00: // no rotate
			begin
				arr_out = arr;
			end
			2'b01: // 90 ccw rotates
			begin
				arr_out[2:0] = arr[5:3];
				for (i = 0; i < 3; i++) begin
					arr_out[i + 3] = - arr[i];				
				end
			end
			2'b10: // 180 rotates
			begin
				for (i = 0; i < 6; i++) begin
					arr_out[i] = - arr[i];		
				end
			end
			2'b11: // -90 cw rotates
			begin
				arr_out[5:3] = arr[2:0];
				for (i = 0; i < 3; i++) begin
					arr_out[i] = - arr[i + 3];				
				end
			end
		endcase
	end //always_comb
	
	// FSM for controlling the data read cycles. Controls the internals for the ROM's data storage.
	enum {waiting, starting, reading} ps, ns;
	always_comb begin
	// default:
	do_xy = 1'b0;
		case(ps) 
			waiting: 
				if(request)
					ns = starting;
				else
					ns = waiting;
			starting:
				if(shape > 3'b100)
					ns = starting;
				else 
					ns = reading;
			reading: 
			begin
				do_xy = 1'b1;
				if(done_xy == 1'b1)
					ns = waiting;
				else 
					ns = reading;
			end
		endcase
	end //always_comb
	
	always_ff @(posedge Clock) begin
		if(reset) 
			ps <= waiting;
		else begin
			ps <= ns;
			data_ready <= done_xy;
			if(ps == starting)
				read_addr <= shape;
		end
	end //always_ff
	
	// FSM for reading the offsets from ROM - the xy coordinate system array giving the 
	// specific dimensional coordiates for the tetris blocks in a array.
	enum {waitingxy, waiting1, waiting2, first, second, third, fourth, fifth, sixth} psxy, nsxy;
	
	always_comb begin 
	//default:
	done_xy = 1'b0;
	inc = 5'b0;
		case(psxy) 
			waitingxy:
				if(do_xy == 1'b1)
					nsxy = waiting1;
				else 
					nsxy = waitingxy;
			waiting1:
				nsxy = waiting2;
			waiting2: begin
				inc = 5'b00001;
				nsxy = first;
				end
			first: begin
				inc = 5'b00010;
				nsxy = second;
				end
			second: begin
				inc = 5'b00011;
				nsxy = third;
			end
			third: begin
				inc = 5'b00100;
				nsxy = fourth;	
			end
			fourth: begin
				inc = 5'b00101;
				nsxy = fifth;	
			end
			fifth: begin
				nsxy = sixth;	
			end
			sixth: begin
				done_xy = 1'b1;
				nsxy = waitingxy;	
			end
		endcase
	end // always_comb 

	always_ff @(posedge Clock) begin
		if(reset) 
			psxy <= waitingxy;
		else begin
			psxy <= nsxy;
			if(psxy == first) 
				arr[5] <= q;
			if(psxy == second)
				arr[4] <= q;
			if(psxy == third)
				arr[3] <= q;
			if(psxy == fourth)
				arr[2] <= q;
			if(psxy == fifth)
				arr[1] <= q;
			if(psxy == sixth)
				arr[0] <= q;
		end
	end // always_ff
	
endmodule //piece_generate

// timescaling the testbench to synch with the library memory module.
`timescale 1 ps / 1 ps
/* testbench for the piece_generate that tests the overall function of the module and outputs 
   produced given the varied inputs. Port connections *see piece_generate module*. */
module piece_generate_testbench();
	logic Clock, reset, request;
	logic [4:0] arr_out[5:0];	
	logic data_ready;
	
	piece_generate dut(.Clock, .reset, .request, .arr_out, .data_ready);
	
	parameter CLOCK_PERIOD = 50;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
	end // initial begin
	
	initial begin
		reset <= 1'b0;									@(posedge Clock);
		reset <= 1'b1;									@(posedge Clock);
		reset <= 1'b0;									@(posedge Clock);

		// generates one shape and if its ready
		request <= 1'b1;								@(posedge Clock);
		request <= 1'b0;								@(posedge Clock);	
		repeat(15) 										@(posedge Clock);
		
		// generates one shape and if its ready
		request <= 1'b1;								@(posedge Clock);
		request <= 1'b0;								@(posedge Clock);	
		repeat(15) 										@(posedge Clock);
		
		// generates one shape and if its ready
		request <= 1'b1;								@(posedge Clock);
		request <= 1'b0;								@(posedge Clock);	
		repeat(15) 										@(posedge Clock);
		
		// generates one shape and if its ready
		request <= 1'b1;								@(posedge Clock);
		request <= 1'b0;								@(posedge Clock);	
		repeat(15) 										@(posedge Clock);
		
		// generates one shape and if its ready
		request <= 1'b1;								@(posedge Clock);
		request <= 1'b0;								@(posedge Clock);	
		repeat(15) 										@(posedge Clock);
		
		// generates one shape and if its ready
		request <= 1'b1;								@(posedge Clock);
		request <= 1'b0;								@(posedge Clock);	
		repeat(15) 										@(posedge Clock);
		
		// generates one shape and if its ready
		request <= 1'b1;								@(posedge Clock);
		request <= 1'b0;								@(posedge Clock);	
		repeat(15) 										@(posedge Clock);
		
		// generates one shape and if its ready
		request <= 1'b1;								@(posedge Clock);
		request <= 1'b0;								@(posedge Clock);	
		repeat(15) 										@(posedge Clock);
		
		// generates one shape and if its ready
		request <= 1'b1;								@(posedge Clock);
		request <= 1'b0;								@(posedge Clock);	
		repeat(15) 										@(posedge Clock);
		
		// generates one shape and if its ready
		request <= 1'b1;								@(posedge Clock);
		request <= 1'b0;								@(posedge Clock);	
		repeat(15) 										@(posedge Clock);
		
	$stop;
	end //initial begin
endmodule //piece_generate_testbench

