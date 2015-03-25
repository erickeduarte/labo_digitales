`timescale 1ns / 1ps

module RAM_DUAL_READ_PORT # ( parameter DATA_WIDTH= 16, parameter ADDR_WIDTH=8, parameter MEM_SIZE=8 )
(
	input wire						Clock,
	input wire						iWriteEnable,
	input wire[ADDR_WIDTH-1:0]	iReadAddress0,
	input wire[ADDR_WIDTH-1:0]	iReadAddress1,
	input wire[ADDR_WIDTH-1:0]	iWriteAddress,
	input wire[DATA_WIDTH-1:0]		 	iDataIn,
	output reg [DATA_WIDTH-1:0] 		oDataOut0,
	output reg [DATA_WIDTH-1:0] 		oDataOut1
);

reg [DATA_WIDTH-1:0] Ram [MEM_SIZE-1:0];		

always @(posedge Clock) 
begin 
	//////// FIX for PIPELINE
	//In case we try to read the value we are being told to write, give that value back
	// Else, just give the data stored
	oDataOut0 <=  ((iWriteAddress == iReadAddress0) && iWriteEnable) ? iDataIn : Ram[iReadAddress0]; 
	oDataOut1 <=  ((iWriteAddress == iReadAddress1) && iWriteEnable) ? iDataIn : Ram[iReadAddress1]; 
	
	if (iWriteEnable) 
		Ram[iWriteAddress] <=  iDataIn; 
		
end 
endmodule

