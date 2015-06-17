
`timescale 1ns / 1ps
`include "Defintions.v"

module MiniAlu
(
 input wire Clock,
 input wire Reset,
 output wire [7:0] oLed,
 output wire oVGA_HSYNC,
 output wire oVGA_VSYNC,
 output wire [2:0] oVgaRgb
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

assign wResult_Pre = (wOperation==`CALL) ? wIP_temp : rResult ;
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
		//$display("%dns ADD %h + %h = %h",$time,wSourceData0,wSourceData1,rResult);
	end
	//-------------------------------------
	`CMP:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rFlagCALL    <= 1'b0;
		rResult      <= -wSourceData1; 
		rVgaWriteEnable <= 1'b0;
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
	end
	//-------------------------------------
	`BLE:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rFlagCALL    <= 1'b0;
		rResult      <= 0;
		rVgaWriteEnable <= 1'b0;
		if (wSourceData1 <= wSourceData0 )
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;
		
	end
	//-------------------------------------
	`BLCD1:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rFlagCALL    <= 1'b0;
		rResult      <= 0;
		rVgaWriteEnable <= 1'b0;
		if (!oSetupReady )
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;
		
	end
	//----------------------	
	/*`BLCD2:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rFlagCALL    <= 1'b0;
		rResult      <= 0;
		if (wpWriteDone )
			begin
				rDoWrite <=1'b0;
				rBranchTaken <= 1'b0;
			end
		else
			rBranchTaken <= 1'b1;
		
	end*/
	//------------------------
	`JMP:
	begin
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
		rFFLedEN     <= 1'b1;
		rWriteEnable <= 1'b0;
		rFlagCALL    <= 1'b0;
		rResult      <= 0;
		rBranchTaken <= 1'b0;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	`SMUL:
	begin
		rVgaWriteEnable <= 1'b0;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b1;
		rFlagCALL    <= 1'b0;
		rResult      <= wSourceData0*wSourceData1;
		rBranchTaken <= 1'b0;
	end
	//-------------------------------------
	`IMUL:
	begin
		rVgaWriteEnable <= 1'b0;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b1;
		rFlagCALL    <= 1'b0;
		rResult <= rRmul1;
//		arrayMUL mul1(wSourceData0,wSourceData1,rResult);
		rBranchTaken <= 1'b0;
	end
	//-------------------------------------
	`gIMUL:
	begin
		rVgaWriteEnable <= 1'b0;
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b1;
		rFlagCALL    <= 1'b0;
		rResult      <= rRgmul1;
//		arrayMUL_GEN mg1(wSourceData0,wSourceData1,rResult);
		rBranchTaken <= 1'b0;
		$display("%dns gIMUL %h * %h = %h",$time,wSourceData0,wSourceData1,rResult);
	end
	//-------------------------------------
	`IMUL2:
	begin
		rVgaWriteEnable <= 1'b0;
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rFlagCALL    <= 1'b0;
		rResult 		 <= rRmux1;
//		muxMUL mx1(wSourceData0,wSourceData1,rRmux1);
	end

	//-------------------------------------
	`IMUX4:
	begin
		rFFLedEN     <= 1'b0;
		rBranchTaken <= 1'b0;
		rWriteEnable <= 1'b1;
		rFlagCALL    <= 1'b0;
		rResult 		 <= rRmux4;
		rVgaWriteEnable <= 1'b0;
//		multiplicador4bits mx4  (wSourceData0,wSourceData1,rRmux4);
	end

	//-------------------------------------
	`VGA:
	begin
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
	`CALL:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b1;
		rResult      <= 0;
		rFlagCALL    <= 1'b1;
		rBranchTaken <= 1'b1;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	`RET:
	begin
		rFFLedEN     <= 1'b0;
		rWriteEnable <= 1'b0;
		rResult      <= 0;
		rFlagCALL    <= 1'b0;
		rBranchTaken <= 1'b1;
		rVgaWriteEnable <= 1'b0;
	end
	//-------------------------------------
	default:
	begin
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


endmodule
