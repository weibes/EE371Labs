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
module task2 (
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
	inout FPGA_I2C_SDAT;
	output logic AUD_XCK;
	input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input logic AUD_ADCDAT;
	output logic AUD_DACDAT;
	
	logic read_ready, write_ready, read, write;
	logic signed [23:0] readdata_left, readdata_right;
	logic signed [23:0] writedata_left, writedata_right;
	logic reset; 
	logic signed [23:0] delay_left1, delay_right1, delay_left2, delay_right2, delay_left3, delay_right3, delay_left4, delay_right4, delay_left5, delay_right5, delay_left6, delay_right6, delay_left7, delay_right7;      
	logic signed [23:0] sum_left1, sum_right1, sum_left2, sum_right2, sum_left3, sum_right3, sum_left4, sum_right4, sum_left5, sum_right5, sum_left6, sum_right6, sum_left7, sum_right7, sum_left0, sum_right0;
	logic signed [23:0] smoothdata_left, smoothdata_right;
	assign reset = ~KEY[0];

	/* Your code goes here */
	
	delay_adder delayleft1(.Clock(CLOCK_50), .enable(read), .D(readdata_left), .Q(delay_left1), .Q_Div(sum_left1));
	delay_adder delayright1(.Clock(CLOCK_50), .enable(read), .D(readdata_right), .Q(delay_right1), .Q_Div(sum_right1));
	
	delay_adder delayleft2(.Clock(CLOCK_50), .enable(read), .D(delay_left1), .Q(delay_left2), .Q_Div(sum_left2));
	delay_adder delayright2(.Clock(CLOCK_50), .enable(read), .D(delay_right1), .Q(delay_right2), .Q_Div(sum_right2));

	delay_adder delayleft3(.Clock(CLOCK_50), .enable(read), .D(delay_left2), .Q(delay_left3), .Q_Div(sum_left3));
	delay_adder delayright3(.Clock(CLOCK_50), .enable(read), .D(delay_right2), .Q(delay_right3), .Q_Div(sum_right3));

	delay_adder delayleft4(.Clock(CLOCK_50), .enable(read), .D(delay_left3), .Q(delay_left4), .Q_Div(sum_left4));
	delay_adder delayright4(.Clock(CLOCK_50), .enable(read), .D(delay_right3), .Q(delay_right4), .Q_Div(sum_right4));

	delay_adder delayleft5(.Clock(CLOCK_50), .enable(read), .D(delay_left4), .Q(delay_left5), .Q_Div(sum_left5));
	delay_adder delayright5(.Clock(CLOCK_50), .enable(read), .D(delay_right4), .Q(delay_right5), .Q_Div(sum_right5));

	delay_adder delayleft6(.Clock(CLOCK_50), .enable(read), .D(delay_left5), .Q(delay_left6), .Q_Div(sum_left6));
	delay_adder delayright6(.Clock(CLOCK_50), .enable(read), .D(delay_right5), .Q(delay_right6), .Q_Div(sum_right6));

	delay_adder delayleft7(.Clock(CLOCK_50), .enable(read), .D(delay_left6), .Q(delay_left7), .Q_Div(sum_left7));
	delay_adder delayright7(.Clock(CLOCK_50), .enable(read), .D(delay_right6), .Q(delay_right7), .Q_Div(sum_right7));	
	
	assign sum_left0 = readdata_left / 8;
	assign sum_right0 = readdata_right / 8;
	
	assign smoothdata_left = (sum_left0 + sum_left1 + sum_left2 + sum_left3 + sum_left4 + sum_left5 + sum_left6 + sum_left7);
	assign smoothdata_right = (sum_right0 + sum_right1 + sum_right2 + sum_right3 + sum_right4 + sum_right5 + sum_right6 + sum_right7);
	
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
				writedata_left <= smoothdata_left;
				writedata_right <= smoothdata_right;
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

