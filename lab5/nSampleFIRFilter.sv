/* module nSampleFIRFilter creates an N sized FIR Filter
	Inputs:
			dataIn is input data to be filtered
			wren is write enable ti sync properly with outside modules
			reen is read enable to sync properly with outside modules
			Clock is clock for synronous operation
	Output:
			dataOut is filtered output data
*/

module nSampleFIRFilter (dataIn, dataOut, wren, reen, Clock);
	input logic wren, reen, Clock;
	input logic signed [23:0] dataIn;
	output logic signed [23:0] dataOut;
	
	parameter N = 1024; // define N to match the FIFO Buffer being used
	logic signed [23:0] dataNormalized, dataBuffer, dataSumBuffer, dataDelayed;
	
	assign dataNormalized = dataIn / N;
	
	// change number after FIFOBuffer (e.g. FIFOBuffer256) to one of available FIFOBuffers
	// match with parameter N above
	FIFOBuffer1024 buffer (.clock(Clock), .data(dataNormalized), .rdreq(reen), .wrreq(wren), .q(dataBuffer));
	delay_adder delay (.Clock, .enable(wren), .D(dataOut), .Q(dataDelayed));
	
	assign dataSumBuffer = (dataBuffer * -1) + dataNormalized;
	assign dataOut = dataDelayed + dataSumBuffer;
	
endmodule // module nSampleFIRFilter

module nSampleFIRFilter_testbench();

	logic wren, reen, Clock;
	logic signed [23:0] dataIn, dataOut;
	
	nSampleFIRFilter dut (.*);
	
	parameter clk_per = 100;
	initial begin
		Clock <= 0;
		forever #(clk_per/2) Clock <= ~Clock;
	end //initial begin
	
	initial begin
		dataIn = $random(90);
		$stop;
	end //initial begin
	
endmodule // module nSampleFIrFilter_testbench