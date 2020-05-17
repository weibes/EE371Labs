/*This module loads data into the TRDB LCM screen's control registers 
 * after system reset. 
 * 
 * Inputs:
 *   CLOCK_50 		- FPGA on board 50 MHz clock
 *   CLOCK2_50  	- FPGA on board 2nd 50 MHz clock
 *   KEY 			- FPGA on board pyhsical key switches
 *   FPGA_I2C_SCLK 	- FPGA I2C communication protocol clock
 *   FPGA_I2C_SDAT  - FPGA I2C communication protocol data
 *   AUD_XCK 		- Audio CODEC data
 *   AUD_DACLRCK 	- Audio CODEC data
 *   AUD_ADCLRCK 	- Audio CODEC data
 *   AUD_BCLK 		- Audio CODEC data
 *   AUD_ADCDAT 	- Audio CODEC data
 *
 * Output:
 *   AUD_DACDAT 	- output Audio CODEC data
 */
module task1 (
	CLOCK_50, 
	CLOCK2_50, 
	KEY, 
	FPGA_I2C_SCLK, 
	FPGA_I2C_SDAT, 
	AUD_XCK, 
	AUD_DACLRCK, 
	AUD_ADCLRCK, 
	AUD_BCLK, 
	AUD_ADCDAT, 
	AUD_DACDAT
);

	input logic CLOCK_50, CLOCK2_50;
	input logic [0:0] KEY;
	output logic FPGA_I2C_SCLK;
	inout logic FPGA_I2C_SDAT;
	output logic AUD_XCK;
	input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input logic AUD_ADCDAT;
	output logic AUD_DACDAT;
	
	logic read_ready, write_ready, read, write;
	logic [23:0] readdata_left, readdata_right;
	logic [23:0] writedata_left, writedata_right;
	logic reset; 
	assign reset = ~KEY[0];

	/* Your code goes here */
	enum {waiting_read, reading, waiting_write, writing} ps, ns;
	
	always_comb begin
	// default:
		read = 1'b0;
		write = 1'b0;
		case(ps) 
		waiting_read: begin
			if(read_ready) ns = reading;
			else ns = waiting_read;
		end
		reading: begin
			read = 1'b1;
			ns = waiting_write;
		end
		waiting_write: begin
			if(write_ready) ns = writing;
			else ns = waiting_write;
		end
		writing: begin
			write = 1'b1;
			ns = waiting_read;
		end
		endcase
	
	end
	
	always_ff @(posedge CLOCK_50) begin
		if(reset)
			ps <= waiting_read;
		else begin
			ps <= ns;
			if(read) begin
				writedata_left <= readdata_left;
				writedata_right = readdata_right;
			end
			
		end
	end
	
	
	//assign writedata_left = 	//Your code goes here 
	//assign writedata_right = 	//Your code goes here 
	//assign read = 				//Your code goes here 
	//assign write = 				//Your code goes here 
	
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

endmodule


