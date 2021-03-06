`timescale 1ns / 1ps
`include "Defintions.v"


module MiniAlu
(
 input wire Clock,
 input wire Reset,
 output wire [7:0] oLed
);

wire [15:0] wIP,wIP_temp;
reg         rWriteEnable0, rWriteEnable1, rBranchTaken, rDoComplement;
wire [27:0] wInstruction;
wire [3:0]  wOperation;
reg  [15:0] rResult0;
reg  [15:0] rResult1;
wire [15:0] wAddSubResult;
wire [7:0]  wSourceAddr0,wSourceAddr1,wDestination;
wire [15:0] wSourceData0,wSourceData0_tmp,wSourceData1,wIPInitialValue,wImmediateValue;

ROM InstructionRom 
(
	.iAddress(     wIP          ),
	.oInstruction( wInstruction )
);

RAM_DUAL_RW_PORT DataRam
(
	.Clock(         Clock        ),
	.iWriteEnable0(  rWriteEnable0 ),
	.iWriteEnable1(  rWriteEnable1 ),
	.iReadAddress0( wInstruction[7:0] ),
	.iReadAddress1( wInstruction[15:8] ),
	.iWriteAddress0( wDestination ),
	.iWriteAddress1( wDestination+1 ),
	.iDataIn0  (       rResult0   ),
	.iDataIn1  (       rResult1   ),
	.oDataOut0 (     wSourceData0 ),
	.oDataOut1 (     wSourceData1 )
);

assign wIPInitialValue = (Reset) ? 8'b0 : wDestination;
UPCOUNTER_POSEDGE # ( 16 ) IP
(
.Clock(   Clock                ), 
.Reset(   Reset | rBranchTaken ),
.Initial( wIPInitialValue + 1  ),
.Enable(  1'b1                 ),
.Q(       wIP_temp             )
);
assign wIP = (rBranchTaken) ? wIPInitialValue : wIP_temp;

FFD_POSEDGE_SYNCRONOUS_RESET # ( 4 ) FFD1 
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[27:24]),
	.Q(wOperation)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD2
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[7:0]),
	.Q(wSourceAddr0)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD3
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[15:8]),
	.Q(wSourceAddr1)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD4
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[23:16]),
	.Q(wDestination)
);


reg rFFLedEN;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FF_LEDS
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( rFFLedEN ),
	.D( wSourceData1 ),
	.Q( oLed    )
);


////////////////////////////////////////////////////////////////////////
/////// InmediateValue is taken directly from SourceAddr1 and SourceAddr2
assign wImmediateValue = {wSourceAddr1,wSourceAddr0};
//
////////////////////////////////////////////////////////////////////////
/////// FOR THE ADD/SUB
assign wSourceData0_tmp = (rDoComplement) ? -wSourceData0 : wSourceData0;
assign wAddSubResult = wSourceData1 + wSourceData0_tmp;
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
wire [15:0] wLUT_result;
LUT_2 mulut 
(
.iData_A(wSourceData0),
.iData_B(wSourceData1),
.oResult(wLUT_result)
);
////////////////////////////////////////////////////////////////////////



always @ ( * )
	case (wOperation)
	//-------------------------------------
	`NOP:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable0 <= 1'b0;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= 0;
		rResult1      <= 0;
	end
	//-------------------------------------
	`ADD:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= wAddSubResult;
		rResult1      <= 0;
	end
		//-------------------------------------
	`SUB:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b1;
		rResult0      <= wAddSubResult;
		rResult1      <= 0;
	end
	//-------------------------------------
	`STO:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b0;
		rBranchTaken <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= wImmediateValue;
		rResult1      <= 0;
	end
	//-------------------------------------
	`BLE:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable0 <= 1'b0;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= 0;
		rResult1      <= 0;
		if (wSourceData1 <= wSourceData0 )
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;
		
	end
	//-------------------------------------	
	`JMP:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable0 <= 1'b0;
		rWriteEnable1 <= 1'b0;
		rResult0      <= 0;
		rResult1      <= 0;
		rDoComplement <= 1'b0;
		
		rBranchTaken <= 1'b1;
	end
	//-------------------------------------	
	`LED:
	begin
		rFFLedEN     <= 1'b1;
		rWriteEnable0 <= 1'b0;
		rWriteEnable1 <= 1'b0;
		rResult0      <= 0;
		rResult1      <= 0;
		rBranchTaken <= 1'b0;
		rDoComplement <= 1'b0;
	end
	`LUT_2:
		begin
			rFFLedEN      <= 1'b0;
			rBranchTaken  <= 1'b0;
			rDoComplement <= 1'b0;
			rWriteEnable0 <= 1'b1; // Write output to RAM
			rWriteEnable1 <= 1'b1; // Write 32 bits output to RAM 
			rResult0      <= wLUT_result; // Asign result to output of LUT multiplication module
			rResult1	  <= 0;
		end
	//-------------------------------------
	/*
	`MUL:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= wSourceData1 * wSourceData0; //multiplicacion   
		rResult1      <= 0;     
	end
	//-------------------------------------
	`SMUL:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= wSSourceData1 * wSSourceData0; //nuevas entradas para rResult0
		rResult1      <= 0;
	end
	//-------------------------------------
	`IMUL:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b0; // No need for complement first argument
        rResult0[15:8]  <= 8'd0; //Bits no utilizados de rResult0 van a 0
		rResult0[7:0]   <= wResult; //Asignacion del resultado de la multiplicacion a rResult0    
		rResult1      <= 0;
	end
	//-------------------------------------
	`IMUL2: // LUT multiplication
		begin
			rFFLedEN      <= 1'b0;
			rBranchTaken  <= 1'b0;
			rDoComplement <= 1'b0;
			rWriteEnable0 <= 1'b1; // Write output to RAM
			rWriteEnable1 <= 1'b0;
			rResult0      <= LUT_Mult_Result; // Asign result to output of LUT multiplication module
			rResult1      <= 0;
		end
	//-------------------------------------
	`LMUL:
		begin
			rFFLedEN      <= 1'b0;
			rBranchTaken  <= 1'b0;
			rDoComplement <= 1'b0;
			rWriteEnable0 <= 1'b1; // Write output to RAM
			rWriteEnable1 <= 1'b1; // Write 32 bits output to RAM 
			rResult0      <= wLMUL_result[15:0]; // Asign result to output of LUT multiplication module
			rResult1      <= wLMUL_result[31:16]; // Asign result to output of LUT multiplication module
		end
		*/
	
	//-------------------------------------
	
	default:
	begin
		rFFLedEN      <= 1'b1;
		rWriteEnable0 <= 1'b0;
		rWriteEnable1 <= 1'b0;
		rResult0      <= 0;
		rResult1      <= 0;
		rBranchTaken  <= 1'b0;
		rDoComplement <= 1'b0;
	end	
	//-------------------------------------	
	endcase	

endmodule
