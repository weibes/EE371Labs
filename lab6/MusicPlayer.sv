/*
module MusicPlayer (CLOCK_50, CLOCK2_50, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,
							  AUD_ADCDAT, AUD_DACDAT, reset, MusicEnable);
	input logic reset, MusicEnable;	
	input CLOCK_50, CLOCK2_50;
	
	output logic FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	output logic AUD_XCK;
	input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input logic AUD_ADCDAT;
	output logic AUD_DACDAT;
	
	// signals from other modules
	logic [23:0] dOut, dOut_A, dOut_b;
	logic write_ready;
	
	// datapath signals
	logic ABSelector, aAgain, write;
	logic [19:0] count;
	
	// control signals
	logic writeZero, writeB, writeA, initCounters, clr_count, aAgain_high, aAgain_low, neg_ABSelector, incr_count;
	
	
	themeAMem memA (.q(dOut_A), .rdaddress, .enable(enableA), .Clock(CLOCK_50)); 
	themeBMem memB (.q(dOut_B), .rdaddress, .enable(enableB), .Clock(CLOCK_50)); 
	
	enum {ready, loop} ps, ns;
	
	always_comb begin
	
	
		// state machine, ps and ns stuff
		case(ps)
			ready: begin
				if (MusicEnable)
					ns = loop;
				else
					ns = ready
			end // ready: begin
			loop:
				ns = loop;
		endcase 
		
		// control outputs
		writeZero = 0;
		writeB = 0;
		writeA = 0;
		initCounters = 0;
		clr_count = 0;
		aAgain_high = 0;
		aAgain_low = 0;
		neg_ABSelector = 0;
		incr_count = 0;
		
		case(ps)
			ready: begin
				if (write_ready)
					writeZero = 1;
				if (MusicEnable)
					initCounters = 1;
			end // ready: begin
			loop: begin
				if (MusicEnable) begin
					if (write_ready) begin
						if (ABSelector) begin // section B is selected
							writeB = 1;
							// magic number comes from number of samples in B section
							if (count == 20'd616325) begin 
								clr_count = 1;
								aAgain_high = 1;
								neg_ABSelector = 1;
							end // if (count == 20'd616325) begin
							else begin
								incr_count = 1;
							end // else begin
						end // if (ABSelector) begin
						else begin // section A is selected
							writeA = 1;
							// magic number comes from number of samples in A section
							if (count == 20'd615732) begin
								clr_count = 1;
								if (aAgain)
									aAgain_low = 1;
								else 
									neg_ABSelector = 1;
							end // if (count == 20'd615732) begin
							else begin
								incr_count = 1;
							end // else begin
						end // else begin
					end // if (write_ready) begin
				end // if (MusicEnable) begin
				else begin
					if (write_ready)
						writeZero - 1;
				end // else begin
			end // loop: begin
		endcase
	end // always_comb
	
		writeZero = 0;
		writeB = 0;
		writeA = 0;
		initCounters = 0;
		clr_count = 0;
		aAgain_high = 0;
		aAgain_low = 0;
		neg_ABSelector = 0;
		incr_count = 0;
		
	
		// datapath signals
	logic ABSelector, aAgain, write;
	logic [19:0] count;
	
	
	
	
	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			ps <= ready;
			ABSelector <= 0;
			aAgain <= 1;
			write <= 0;
			count <= 0;
			dOut <= 0;
		end // if (reset) begin
		else begin
			ps <= ns;
			//write, dOut signal
			if (writeZero) begin
				dOut <= 0;
				write <= 1;
			end // if (writeZero) begin
			else if (writeA) begin
				dOut <= dOut_A;
				write <= 1;
			end // else if (writeA) begin
			else if (writeB) begin
				dOut <= dOut_B:
				write <= 1;
			end // else if (writeB) begin
			else
				write <= 0;
			
			// cnt signal
			if (clr_cnt || initCounters) 
				count <= 0;
			else if (incr_count)
				count <= count + 1;
			
			//
		end // else begin
	end // always_ff @(posedge CLOCK_50) begin
	
	
	clock_generator my_clock_gen(
		.CLOCK2_50,
		.reset,
		.AUD_XCK
	);

	audio_and_video_config cfg(
		.CLOCK_50,
		.reset,
		.FPGA_I2C_SDAT,
		.FPGA_I2C_SCLK
	);

	audio_codec codec(
		.CLOCK_50,
		.reset,
		.read(1'b0),	
		.write,
		.writedata_left(dOut), 
		.writedata_right(dOut),
		.AUD_ADCDAT,
		.AUD_BCLK,
		.AUD_ADCLRCK,
		.AUD_DACLRCK,
		.write_ready, // .read_ready, 
		//.readdata_left, .readdata_right,
		.AUD_DACDAT
	);
endmodule // module MusicPlayer
*/
