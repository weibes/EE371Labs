module nSampleFIRFilter #(parameter N=16) (dataIn, dataOut, enable, Clock);
	input logic enable, Clock;
	input logic signed [23:0] dataIn;
	output logic signed [23:0] dataOut;
	
	logic signed [23:0] dataNormalized, dataBuffer, dataSumBuffer, dataDelayed;
	
	assign dataNormalized = dataIn / N;
	
	FIFOBuffer16 buffer (.clock(Clock), .data(dataNormalized), .rdreq(enable), .wrreq(enable), .q(dataBuffer));
	delay_adder delay (.Clock, .enable, .D(dataOut), .Q(dataDelayed));
	
	assign dataSumBuffer = (dataBuffer * -1) + dataNormalized;
	assign dataOut = dataDelayed + dataSumBuffer;

	
endmodule // module nSampleFIRFilter

module nSampleFIRFilter_testbench();

	logic enable, Clock;
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