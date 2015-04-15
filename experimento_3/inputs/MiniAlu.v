`timescale 1ns / 1ps
`include "Defintions.v"


module MiniAlu
(
 input wire Clock,
 input wire Reset,
 output wire [7:0] oLed
);

wire [15:0] wIP,wIP_temp;
reg         rWriteEnable0, rWriteEnable1, rBranchTaken, rDoComplement,rSubR,rReturn ;
wire [27:0] wInstruction;
wire [3:0]  wOperation;
reg  [15:0] rResult0;
reg  [15:0] rResult1;
reg  [7:0]  wInstructiontmep,wDestinationtemp ;
wire [15:0] wAddSubResult;
wire [7:0]  wSourceAddr0,wSourceAddr1,wDestination;
wire [15:0] wSourceData0,wSourceData0_tmp,wSourceData1,wIPInitialValue,wImmediateValue;
// --------------------------
ROM InstructionRom 
(
	.iAddress(     wIP          ),
	.oInstruction( wInstruction )
);
/*
always (posedge Clock)
begin
	// Reviso si se esta brincando a una subrurina o retornando
	if (rSubR = 1)
		begin
			wInstructiontmep = wInstruction[7:0];	
			wDestinationtemp = R7;				
		end

	if (rReturn = 1)
		begin
			wInstructiontmep = R7;
			wDestinationtemp = wDestination;
		end
	else 
		begin
			wInstructiontmep = wInstruction[7:0];	
			wDestinationtemp = wDestination;
		end
end
*/

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
//// LCD Display Controller
////////////////////////////////////////////////////////////////////////

// ----- FOR LCD Display ----
wire 		wLCD_Ready;			// Handshake protocol -- ready to receive
reg			rLCD_Data_Ready;	// Handshake protocol -- send data ready
wire 		wLCD_Enabled, wLCD_RegisterSelect, wLCD_StrataFlashControl, wLCD_ReadWrite; // Outputs from the module
wire [3:0] 	wLCD_Data; 			// Output data to LCD display 
Module_LCD_Control LCD
(
	.Clock(Clock),										// 	Runs @50MHz
	.Reset(Reset),										// 	Resets state machine, and counter
	.oLCD_Enabled(wLCD_Enabled),						// 	Read/Write Enable Pulse -||- 0: Disabled -||- 1: Read/Write operation enabled
	.oLCD_RegisterSelect(wLCD_RegisterSelect), 			// 	Register Select 0=Command, 1=Data || 0: Instruction register during write operations. Busy Flash during read operations -- 1: Data for read or write operations
	.oLCD_StrataFlashControl(wLCD_StrataFlashControl),	//	
	.oLCD_ReadWrite(wLCD_ReadWrite),					// 	Read/Write Control 0: WRITE, LCD accepts data 1: READ, LCD presents data || ALWAYS WRITE
	.oLCD_Data(wLCD_Data),								// 	4 BIT Data OutPut to LCD Display
	.iData(rResult0[15:8]),								// 	8 BIT Data to be shown on the LCD screen
	.oReadyForData(wLCD_Ready),							// 	Flag that indicates wheter or not the controller is ready to print data
	.iData_Ready(rLCD_Data_Ready)						// 	Flag that indicates that the data is ready to be acepted by controller
);
////////////////////////////////////////////////////////////////////////


always @ ( * )
	case (wOperation)
	//-------------------------------------
	`NOP:
	begin
		rLCD_Data_Ready <= 0;
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable0 <= 1'b0;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= 0;
		rResult1      <= 0;
		rReturn		<=1'b0;
		rSubR		<=1'b0;
	end
	//-------------------------------------
	`ADD:
	begin
		rLCD_Data_Ready <= 0;
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= wAddSubResult;
		rResult1      <= 0;
		rReturn		<=1'b0;
		rSubR		<=1'b0;
	end
		//-------------------------------------
	`SUB:
	begin
		rLCD_Data_Ready <= 0;
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b1;
		rResult0      <= wAddSubResult;
		rResult1      <= 0;
		rReturn		<=1'b0;
		rSubR		<=1'b0;
	end
	//-------------------------------------
	`STO:
	begin
		rLCD_Data_Ready <= 0;
		rFFLedEN     <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b0;
		rBranchTaken <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= wImmediateValue;
		rResult1      <= 0;
		rReturn		<=1'b0;
		rSubR		<=1'b0;
	end
	//-------------------------------------
	`BLE:
	begin
		rLCD_Data_Ready <= 0;
		rFFLedEN     <= 1'b0;
		rWriteEnable0 <= 1'b0;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= 0;
		rResult1      <= 0;
		rReturn		<=1'b0;
		rSubR		<=1'b0;
		if (wSourceData1 <= wSourceData0 )
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;

		
	end
	//-------------------------------------	
	`JMP:
	begin
		rLCD_Data_Ready <= 0;
		rFFLedEN     <= 1'b0;
		rWriteEnable0 <= 1'b0;
		rWriteEnable1 <= 1'b0;
		rResult0      <= 0;
		rResult1      <= 0;
		rDoComplement <= 1'b0;
		
		rBranchTaken <= 1'b1;
		rReturn		<=1'b0;
		rSubR		<=1'b0;
	end
	//-------------------------------------	
	`CALL:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b1;
		rResult0      <= wIPInitialValue;
		rResult1      <= 0;
		rDoComplement <= 1'b0;
		rBranchTaken <= 1'b1;
		rReturn		<=1'b0;
		rSubR		<=1'b1;
	end
	//-------------------------------------	
	`RET:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable0 <= 1'b0;
		rWriteEnable1 <= 1'b0;
		rResult0      <= 0;
		rResult1      <= 0;
		rDoComplement <= 1'b0;
		rBranchTaken <= 1'b1;
		rReturn		<=1'b1;
		rSubR		<=1'b0;
	end
	//-------------------------------------	
	`LED:
	begin
		rLCD_Data_Ready <= 0;
		rFFLedEN     <= 1'b1;
		rWriteEnable0 <= 1'b0;
		rWriteEnable1 <= 1'b0;
		rResult0      <= 0;
		rResult1      <= 0;
		rBranchTaken <= 1'b0;
		rDoComplement <= 1'b0;
		rReturn		<=1'b0;
		rSubR		<=1'b0;
	end
	//-------------------------------------
	`MUL:
	begin
		rLCD_Data_Ready <= 0;
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable0 <= 1'b1;
		rWriteEnable1 <= 1'b0;
		rDoComplement <= 1'b0;
		rResult0      <= wSourceData1 * wSourceData0; //multiplicacion   
		rResult1      <= 0;     
		rReturn		<=1'b0;
		rSubR		<=1'b0;
	end
	//-------------------------------------
	`BNLCD: // Branch if LCD not ready
		begin
			rFFLedEN      <= 1'b0;
			rWriteEnable0 <= 1'b0;
			rWriteEnable1 <= 1'b0;
			rDoComplement <= 1'b0;
			rResult1      <= 0;
			rReturn		<=1'b0;
			rSubR		<=1'b0;
			/////////////////////////////////
			rLCD_Data_Ready <= 0; // Not ready to send data to LCD
			if (wLCD_Ready)
				rBranchTaken <= 1'b0;
			else
				rBranchTaken <= 1'b1;
		end
	//-------------------------------------
	`LCD:
		begin
			rReturn		<=1'b0;
			rSubR		<=1'b0;
			rFFLedEN      <= 1'b0;
			rWriteEnable0 <= 1'b0;
			rWriteEnable1 <= 1'b0;
			rDoComplement <= 1'b0;
			rResult1      <= 0;
			rBranchTaken <= 1'b0;
			/////////////////////////////////
			rLCD_Data_Ready <= 1; 				// Ready to send data
			rResult0      	<= wImmediateValue; // LCD reads from first 8 bits of rResult0
			
		end
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
			rReturn		<=1'b0;
			rSubR		<=1'b0;
			rLCD_Data_Ready <= 0;
		end	
	//-------------------------------------	
	endcase	

endmodule
