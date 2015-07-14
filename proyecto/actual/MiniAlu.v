
`timescale 1ns / 1ps
`include "Defintions.v"

module MiniAlu
(
 input wire Clock,
 input wire Reset,
 input wire Move,
 output wire [7:0] oLed,
 output wire oVGA_HSYNC,
 output wire oVGA_VSYNC,
 output wire [2:0] oVgaRgb,
 input wire BTN_EAST,
 input wire BTN_WEST,
 input wire BTN_NORTH,
 input wire BTN_SOUTH
);

localparam RESOL_X = 100;
localparam RESOL_Y = 100;

wire [15:0]  wIP,wIP_temp;
reg         rWriteEnable,rBranchTaken,rVgaWriteEnable;
wire [27:0] wInstruction;
wire [7:0] wSourceAddr0Pre;
reg rFlagCALL;

wire [3:0]  wOperation, wOperation_Pre;
reg signed [15:0] rResult;
wire [15:0] wResult_Pre;
wire [7:0]  wSourceAddr0,wSourceAddr1,wDestination, wDestination_Pre, wDestOpAnterior0, wDestOpAnterior1;
wire [15:0] wSourceData0,wSourceData1,wIPInitialValue,wImmediateValue;
wire [9:0] wCurrentRow,wCurrentCol;

ROM InstructionRom 
(
	.iAddress(     wIP          ),
	.oInstruction( wInstruction )
);

RAM_DUAL_READ_PORT DataRam
(
	.Clock(         Clock        ),
	.iWriteEnable(  rWriteEnable ),
	.iReadAddress0( wSourceAddr0Pre ),
	.iReadAddress1( wInstruction[15:8] ),
	.iWriteAddress( wDestination_Pre ),
	.iDataIn(       wResult_Pre      ),
	.oDataOut0(     wSourceData0 ),
	.oDataOut1(     wSourceData1 )
);

wire [2:0]  wColorReadData;
reg[2:0]  rColorWriteData ;
wire [15:0] wCurrentReadColor ;
wire [15:0] wColorWriteAddress ;
	
RAM_DUAL_READ_PORT #(.DATA_WIDTH(3), .ADDR_WIDTH(16), .MEM_SIZE(RESOL_X*RESOL_Y)) VGARam
(
	.Clock(         Clock        ),
	.iWriteEnable(  rVgaWriteEnable ),
	.iReadAddress0( wCurrentReadColor ),	//Goes into VGA controller module
	.iReadAddress1( 16'b0 ),
	.iWriteAddress( wColorWriteAddress ),	//From main MiniAlu switch statement
	.iDataIn(       rColorWriteData    ),	//From main MiniAlu switch statement
	.oDataOut0(     wColorReadData 	  )
	

);





localparam FRAME_WIDTH_X = (270+48);	//Width + Front Porch
localparam FRAME_WIDTH_Y = (190+29);	//Width + Front Porch

wire wNotInFrame;
assign wNotInFrame = ( 
								   (wCurrentCol < FRAME_WIDTH_X || wCurrentCol > FRAME_WIDTH_X + 100) //Not in X
								|| (wCurrentRow < FRAME_WIDTH_Y || wCurrentRow > FRAME_WIDTH_Y + 100)
							);

assign wCurrentReadColor  = (wNotInFrame) ? 0 : 
RESOL_X*(wCurrentRow -FRAME_WIDTH_Y) + wCurrentCol - FRAME_WIDTH_X;


assign wColorWriteAddress = wSourceData0*RESOL_X + wSourceData1;

assign wIPInitialValue = (Reset) ? 8'b0 :((wOperation_Pre==`RET) ? wSourceData0 :wDestination);
assign wIP = (rBranchTaken | (wOperation_Pre==`RET)) ? wIPInitialValue : wIP_temp;

assign wResult_Pre = (wOperation==`RET) ? wIP_temp : rResult ;
assign wSourceAddr0Pre = (wOperation==`RET) ? 8'd7 : wInstruction[7:0];
assign  wDestination_Pre = (rFlagCALL) ? 8'd7 : wDestination ; //wDestination_Pre => iWriteAddress



// FF que retiene la instruccion un cicle, la instruccion es igual.
FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFDM 
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wOperation),
	.Q(wOperation_Pre)
);

UPCOUNTER_POSEDGE IP
(
.Clock(   Clock                ), 
.Reset(   Reset | rBranchTaken | (wOperation_Pre==`RET)),
.Initial( wIPInitialValue + 1  ),
.Enable(  1'b1                 ),
.Q(       wIP_temp             )
);


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


wire [7:0] rRmul1, rRmux1, rRmux4;
wire [15:0] rRgmul1;
reg[7:0] rLCDData;
reg oSetupReady;
reg oWriteDone;
reg[3:0] oLCD_Data;
reg rDoWrite;
wire oLCD_Enabled,oLCD_RegisterSelect,oLCD_StrataFlashControl, oLCD_ReadWrite;

arrayMUL mul1(wSourceData0,wSourceData1,rRmul1);

arrayMUL_GEN mg1(wSourceData0,wSourceData1,rRgmul1);

muxMUL mx1(wSourceData0,wSourceData1,rRmux1);

multiplicador4bits mx4  (wSourceData0,wSourceData1,rRmux4);
//Module_LCD_Control control1(Clock,Reset,oLCD_Enabled,oLCD_RegisterSelect,oLCD_StrataFlashControl, oLCD_ReadWrite,rDoWrite,rLCDData,oSetupReady,oWriteDone,oLCD_Data);


 
assign wImmediateValue = {wSourceAddr1,wSourceAddr0};




reg rPreReset; 
reg  rFlag;
wire [2:0]wClock25Mhz;

always @ (posedge Clock )
begin
	if (rFlag)
		begin 
			rPreReset = 1'b0;
		end
	else
		begin
			rPreReset = 1'b1;
			rFlag = 1'b1;
		end
end


UPCOUNTER_POSEDGE #(2) CLOCK25
(
.Clock(   Clock                ), 
.Reset(   rPreReset             ),
.Initial( 0                    ),
.Enable(  1'b1                 ),
.Q(       wClock25Mhz          )
);



VGA_Controller_Josue  # (.RESOL_X(RESOL_X), .RESOL_Y(RESOL_Y) ) c1

(
	.Clock25(wClock25Mhz[0]), 
	.Reset(Reset),
	.iRGB(  wColorReadData ),
   .H_Sync(oVGA_HSYNC), 
	.V_Sync(oVGA_VSYNC),
   .oRGB(oVgaRgb),
   .Cont_X(wCurrentCol),
	.Cont_Y(wCurrentRow)
  );
///////////////////////////////////////////////
 reg BTN_ACK;
wire TMP_EAST, TMP_WEST, TMP_NORTH, TMP_SOUTH;
wire XOR_EAST, XOR_WEST, XOR_NORTH, XOR_SOUTH;
wire B_EAST;

///////////////////////////////////////////////
always @ ( * )
begin
	case (wOperation)
	//-------------------------------------
	`NOP:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rFlagCALL    <= 1'b0;
		rResult      <= 0;
		rVgaWriteEnable <= 1'b0;
		BTN_ACK 	<= 0;
	end
	//-------------------------------------
	//-------------------------------------
	`LCD:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b0;
		rFlagCALL    <= 1'b0;
		rResult      <= 0;
		rLCDData=wSourceData1;
		rDoWrite=1'b1;
		rVgaWriteEnable <= 1'b0;
		BTN_ACK 	<= 0;
	end
	//-------------------------------------
	`ADD:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rFlagCALL    <= 1'b0;
		rResult      <= wSourceData1 + wSourceData0;
		rVgaWriteEnable <= 1'b0;
		BTN_ACK 	<= 0;
		//$display("%dns ADD %h + %h = %h",$time,wSourceData0,wSourceData1,rResult);
	end
	//-------------------------------------
	`SUB:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rFlagCALL    <= 1'b0;
		rResult      <= wSourceData1-wSourceData0; 
		rVgaWriteEnable <= 1'b0;
		BTN_ACK 	<= 0;
		// $display("%dns CMP %h = %h",$time,wSourceData1,rResult);
	end
	//-------------------------------------
	`STO:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b1;
		rBranchTaken <= 1'b0;
		rFlagCALL    <= 1'b0;
		rVgaWriteEnable <= 1'b0;
		rResult      <= wImmediateValue;
		BTN_ACK 	<= 0;
	end
	//-------------------------------------
	`BLE:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rFlagCALL    <= 1'b0;
		rResult      <= 0;
		rVgaWriteEnable <= 1'b0;
		BTN_ACK 	<= 0;
		if (wSourceData1 <= wSourceData0 )
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;
		
	end
	
	//------------------------
	`JMP:
	begin
		BTN_ACK 	<= 0;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rFlagCALL    <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b1;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------	
	`LED:
	begin
		BTN_ACK 	<= 0;
		rFFLedEN     <= 1'b1;
		rWriteEnable <= 1'b0;
		rFlagCALL    <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b0;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	`VGA:
	begin
		BTN_ACK 	<= 0;
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rResult 		 <= 1'b0;
		rVgaWriteEnable <= 1'b1;
		rColorWriteData  <={wDestination[7],wDestination[6],wDestination[5]};
		
		//wColorWriteAddress = wSourceData0*RESOL_X + wSourceData1;
		$display("%dns VGA Color = %b (%d,%d) Addr %x",$time,rColorWriteData,
		wSourceData1,wSourceData0*RESOL_X,wColorWriteAddress);
		

	end
	//-------------------------------------
	`BCLOSE:
	begin
		BTN_ACK 	<= 0;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rFlagCALL    <= 1'b0;
		rBranchTaken <= (((wSourceData1 > wSourceData0)?(wSourceData1-wSourceData0):(wSourceData0-wSourceData1))<5);
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	`RET:
	begin
		BTN_ACK 	<= 0;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rFlagCALL    <= 1'b0;
		rBranchTaken <= 1'b1;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	//-------------------------------------
	`CPY:
	begin
		BTN_ACK 	<= 0;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b1;
		rResult      <= wSourceData0;
		rFlagCALL    <= 1'b0;
		rBranchTaken <= 1'b0;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	`BEAST:
		begin
		BTN_ACK 	<= BTN_EAST;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rFlagCALL    <= 1'b0;
		rBranchTaken <=  BTN_EAST;//B_EAST;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	`BWEST:
	begin
		BTN_ACK		<= BTN_WEST;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rFlagCALL    <= 1'b0;
		rBranchTaken <= BTN_WEST;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	`BNORTH:
	begin
		BTN_ACK 	<= BTN_NORTH;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rFlagCALL    <= 1'b0;
		rBranchTaken <= BTN_NORTH;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	`BSOUTH:
	begin	
		BTN_ACK		<= BTN_SOUTH;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rFlagCALL    <= 1'b0;
		rBranchTaken <= BTN_SOUTH;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	default:
	begin
		BTN_ACK	<= 0;
		rFFLedEN     <= 1'b1;
		rWriteEnable <= 1'b0;
		rFlagCALL    <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b0;
		rVgaWriteEnable <= 1'b0;
	end	
	//-------------------------------------	
	endcase	
end


FFD_POSEDGE_SYNCRONOUS_RESET # ( 4 ) TMPS 
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D({BTN_EAST, BTN_WEST, BTN_NORTH, BTN_SOUTH}),
	.Q({TMP_EAST, TMP_WEST, TMP_NORTH, TMP_SOUTH})
);


assign XOR_EAST = BTN_EAST ^ TMP_EAST;
assign XOR_WEST = BTN_WEST ^ TMP_WEST;
assign XOR_NORTH = BTN_NORTH ^ TMP_NORTH;
assign XOR_SOUTH = BTN_SOUTH ^ TMP_SOUTH;



UPCOUNTER_POSEDGE # ( 1 ) EAST 
(
		.Clock(   Clock ), 
		.Reset(   Reset ),
		.Initial( 1'b0  ),
		.Enable(  XOR_EAST  | BTN_ACK  ),
		.Q(  B_EAST 	)
);

/*
UPCOUNTER_POSEDGE # ( 3 ) EAST 
(
		.Clock(   Clock ), 
		.Reset(   Reset),
		.Initial( 1'b0  ),
		.Enable(  BTN_EAST    ),
		.Q(  BUS_EAST 	)
);
*/
endmodule
