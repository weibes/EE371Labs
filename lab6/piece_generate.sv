module piece_generate(Clock, reset, request, arr_out, data_ready); 
	input logic Clock, reset, request;
	output logic [4:0] arr_out[5:0];
	output logic data_ready;
	
	logic [4:0] arr[5:0];
	logic [2:0] shape, read_addr;
	logic [1:0] rotate;
	logic do_xy, done_xy;
	logic [4:0] read, q, inc;
	
	// the read signal = 6 * read_addr
	assign read = {read_addr, 2'b0} + {1'b0, read_addr, 1'b0} + inc;
	
	LFSR10 random(.Clock, .reset, .Q_out1(shape), .Q_out2(rotate));
	ROM rom(.address(read), .clock(Clock), .rden(1'b1), .q);
	
	// choose random rotations for the blocks.
	always_comb begin
		integer i;
		case(rotate) 
			2'b00: 
			begin // no rotate
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
	end
	
	// FSM for controlling the data read cycle.
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
	end
	
	always_ff @(posedge Clock) begin
		if(reset) 
			ps <= waiting;
		else begin
			ps <= ns;
			data_ready <= done_xy;
			if(ps == starting)
				read_addr <= shape;
		end
	end
	
	// FSM for reading the offsets from ROM - xy values.
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
	end

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
	end
endmodule


`timescale 1 ps / 1 ps
module piece_generate_testbench();
	logic Clock, reset, request;
	logic [4:0] arr_out[5:0];	
	logic data_ready;
	
	piece_generate dut(.Clock, .reset, .request, .arr_out, .data_ready);
	
	parameter CLOCK_PERIOD = 50;
		initial begin
			Clock <= 0;
			forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
	end // initial
	
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
	end
endmodule

