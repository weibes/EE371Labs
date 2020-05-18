module nSampleFIRFilter #(parameter N=16) (dataIn, dataOut, wren, reen, Clock);
	input logic wren, reen, Clock;
	input logic signed [23:0] dataIn;
	output logic signed [23:0] dataOut;
	
	logic signed [23:0] dataNormalized, dataBuffer, dataSumBuffer, dataDelayed;
	
	assign dataNormalized = dataIn / N; //N should be 16 rn, but just for test make 32
	
	FIFOBuffer16 buffer (.clock(Clock), .data(dataNormalized), .rdreq(reen), .wrreq(wren), .q(dataBuffer));
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

		$stop;
	end //initial begin
	
endmodule // module nSampleFIrFilter_testbench