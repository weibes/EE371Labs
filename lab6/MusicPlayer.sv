/* 
 * Module MusicPlayer plays music during gameplay
*/

module MusicPlayer(CLOCK_50, CLOCK2_50, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,
						  AUD_ADCDAT, AUD_DACDAT, reset, MusicEnable);
	input logic reset, MusicEnable;	
	input CLOCK_50, CLOCK2_50;
	
	output logic FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	output logic AUD_XCK;
	input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input logic AUD_ADCDAT;
	output logic AUD_DACDAT;
	
	
	// hooks up the internal signals and internal reset signal for the system.
	logic read_ready, write_ready, read, write;
	logic [23:0] readdata_left, readdata_right;
	logic [23:0] writedata_left, writedata_right;

	/* Creates an FSM to assert ready signals to be read and write appropriately*/
	enum {waiting_read, reading, waiting_write, writing} ps, ns;
	
	always_comb begin
	// default:
		read = 1'b0;
		write = 1'b0;
		case(ps) 
		waiting_read: begin
			if(read_ready && MusicEnable) ns = reading;
			else ns = waiting_read;
		end
		reading: begin
			read = 1'b1;
			ns = waiting_write;
		end
		waiting_write: begin
			if(write_ready && MusicEnable) ns = writing;
			else ns = waiting_write;
		end
		writing: begin
			write = 1'b1;
			ns = waiting_read;
		end
		endcase
	
	end //always_comb
	
	always_ff @(posedge CLOCK_50) begin
		if(reset)
			ps <= waiting_read;
		else begin
			ps <= ns;
			if(read) begin
				writedata_left <= readdata_left;
				writedata_right <= readdata_right;
			end
		end
	end //always_ff
	
	// instantiates the connected modules within the top level module of task1
	clock_generator my_clock_gen(
		CLOCK2_50,
		reset,
		AUD_XCK
	);

	audio_and_video_config cfg(
		CLOCK_50,
		reset,
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		CLOCK_50,
		reset,
		read,	
		write,
		writedata_left, 
		writedata_right,
		AUD_ADCDAT,
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);
		

endmodule // module MusicPlayer
