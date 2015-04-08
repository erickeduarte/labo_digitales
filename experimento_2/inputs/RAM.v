`timescale 1ns / 1ps

module RAM_DUAL_RW_PORT # ( parameter DATA_WIDTH= 16, parameter ADDR_WIDTH=8, parameter MEM_SIZE=8 )
(
	input wire						Clock,
	input wire						iWriteEnable0,
	input wire						iWriteEnable1,
	input wire [ADDR_WIDTH-1:0]	iReadAddress0,
	input wire [ADDR_WIDTH-1:0]	iReadAddress1,
	input wire [ADDR_WIDTH-1:0]	iWriteAddress0,
	input wire [ADDR_WIDTH-1:0]	iWriteAddress1,
	input wire [DATA_WIDTH-1:0]	iDataIn0,
	input wire [DATA_WIDTH-1:0]	iDataIn1,
	output reg [DATA_WIDTH-1:0] 	oDataOut0,
	output reg [DATA_WIDTH-1:0] 	oDataOut1
);

reg [DATA_WIDTH-1:0] Ram [MEM_SIZE-1:0];		

always @(posedge Clock) 
begin 
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//////// FIX for PIPELINE
	//In case we try to read the value we are being told to write, give that value back
	// Else, just give the data stored
	if(! iWriteEnable1)
		begin
			oDataOut0 <=  ((iWriteAddress0 == iReadAddress0) && iWriteEnable0) ? iDataIn0 : Ram[iReadAddress0]; 
			oDataOut1 <=  ((iWriteAddress0 == iReadAddress1) && iWriteEnable0) ? iDataIn0 : Ram[iReadAddress1]; 
		end
	else 
		begin
			if (iWriteEnable0) 
				begin
					oDataOut0 <=  (iWriteAddress0 == iReadAddress0) ? iDataIn0 : ((iWriteAddress1 == iReadAddress0) ? iDataIn1: Ram[iReadAddress0]); 
					oDataOut1 <=  (iWriteAddress0 == iReadAddress1) ? iDataIn0 : ((iWriteAddress1 == iReadAddress1) ? iDataIn1: Ram[iReadAddress1]); 
				end
			else 
				///// Case where you only write in Address1
				begin
					oDataOut0 <=  (iWriteAddress1 == iReadAddress0) ? iDataIn1 : Ram[iReadAddress0]; 
					oDataOut1 <=  (iWriteAddress1 == iReadAddress1)  ? iDataIn1 : Ram[iReadAddress1]; 
				end
		end
	///////////////////////////////////////////////////////////////////////////////////////////////////
	if (iWriteEnable0) 
		Ram[iWriteAddress0] <=  iDataIn0;

	if (iWriteEnable1) 
		Ram[iWriteAddress1] <=  iDataIn1; 
		
end 
endmodule
