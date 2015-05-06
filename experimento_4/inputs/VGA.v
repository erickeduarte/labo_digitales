////////////////////////////////////////////////////////////////////////
//// STATES:
`define STATE_VSYNC					0
`define STATE_BACK_PORCH_VSYNC		1
`define STATE_FRONT_PORCH_VSYNC		2
`define STATE_HSYNC					3
`define STATE_BACK_PORCH_HSYNC		4
`define STATE_FRONT_PORCH_HSYNC		5
`define	STATE_SEND_ROW				6


////////////////////////////////////////////////////////////////////////
/// MODULE:	VGA Controller 
////////////////////////////////////////////////////////////////////////
module VGA_Controller
(
input  wire		  	Clock,
input  wire		  	Reset,
output reg [19:0] 		oReadAddress
output	wire 			oVGA_Red,
output	wire 			oVGA_Green,
output	wire 			oVGA_Blue,
input 	wire [2:0]		wColorFromVideoMemory,
output reg				oHSync,
output	reg				oVSync,
);	
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/// REG DEFINITIONS
reg 	[9:0] Column_index; 	// Counts from 0 to 640 
reg		[8:0] Row_index;		// Counts from 0 to 480
reg 	Row_reset;				// Reset for the Row Counter
reg		Colum_reset;			// Reset for the Column Counter
reg [2:0] Current_State; 		// Current State
reg [2:0] Next_State; 			// Next State
reg [32:0] rTimeCount;			// Counter
reg 	rTimeCountReset;		// Counter Reset
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
/*
	Will be using 256*256 RAM. So ROW starts in 112 ends in (112+256=368). Else is black
	COLUMN starts in 192 ends in (192+256=448). Else is black
*/
// Read next signal
assign oReadAddress = ( wCurrentRow < 112 || wCurrentRow > 368 || CurrentCol < 192 || CurrentCol > 448 ) : 0 : (Row_index-112)*256+Column_index-192;
// Assign color ouputs
assign {oRed,oGreen,oBlue} = ( wCurrentRow < 112 || wCurrentRow > 368 || CurrentCol < 192 || CurrentCol > 448 ) : {0,0,0} : wColorFromVideoMemory;
////////////////////////////////////////////////////////////////////////

//	Next State and delay logic
always @ ( posedge Clock )
begin
	if (Reset)
		begin
			rCurrentState <= `STATE_BACK_PORCH_VSYNC;
			Column_index = 0;
			Row_index = 0;
			rTimeCount <= 32'b0;
		end
	else
		begin
			// Column index increasing logic
			if (Column_reset)
				Column_index = 0;
			else
				Column_index <= Column_index + 9'b1;
			
			// Time counter Logic
			if (rTimeCountReset)
				rTimeCount <= 32'b0;
			else
				rTimeCount <= rTimeCount + 32'b1;
			// Move on to next state
			rCurrentState <= rNextState;
	end
end
//----------------------------------------------------------------------//



always @ ( * )
	begin
		case (rCurrentState)
			/*//////////////////////////////////////////////////////////
				STATE_BACK_PORCH_VSYNC:
					Wait 928us => 23200 Cycles
			//////////////////////////////////////////////////////////*/
			`STATE_BACK_PORCH_VSYNC:
				begin
					oVSync = 1;
					oHSync = 1;
					Column_reset = 1;
					if (rTimeCount < 32'd23200  )
						begin
							rNextState = `STATE_BACK_PORCH_VSYNC;
							rTimeCountReset = 0;
						end
					else 
						begin
							rNextState = `STATE_VSYNC;
							rTimeCountReset = 1;
						end
				end
			/*//////////////////////////////////////////////////////////
				STATE_VSYNC:
					Do a VSync and start over filling the screen. This 
					resets to the first row. Waits 64us => 1600 Cycles
			//////////////////////////////////////////////////////////*/
			`STATE_VSYNC:
				begin
					oVSync = 0;
					oHSync = 1;
					Row_index = 0;
					Column_reset = 1;
					if (rTimeCount < 32'd1600  )
						begin
							rNextState = `STATE_VSYNC;
							rTimeCountReset = 0;
						end
					else 
						begin
							rNextState = `STATE_BACK_PORCH;
							rTimeCountReset = 1;
						end
				end
			/*//////////////////////////////////////////////////////////
				STATE_FRONT_PORCH_VSYNC:
					Waits for 320us => 8000 Cycles
			//////////////////////////////////////////////////////////*/
			`STATE_FRONT_PORCH_VSYNC:
				begin
					oVSync = 1;
					oHSync = 1;
					Column_reset = 1;
					if (rTimeCount < 32'd8000  )
						begin
							rNextState = `STATE_FRONT_PORCH;
							rTimeCountReset = 0;
						end
					else 
						begin
							rNextState = `STATE_SEND_ROW;
							Column_reset = 1;
						end
				end
			/*//////////////////////////////////////////////////////////
				STATE_HSYNC:
					Resets column, Holds HSync on low for 3.84us => 96 Cycles
			//////////////////////////////////////////////////////////*/
			`STATE_HSYNC:
				begin
					oVSync = 1;
					oHSync = 0;
					Column_reset = 1;
					Row_index = Row_index + 1;  	// Move on to next Row
					if (rTimeCount < 32'd96 )
						begin
							rNextState = `STATE_HSYNC;
							rTimeCountReset = 0;
						end
					else 
						begin
							rNextState = `STATE_FRONT_PORCH_HSYNC;
							rTimeCountReset = 1;
						end
				end
			/*//////////////////////////////////////////////////////////
				STATE_BACK_PORCH_HSYNC:
					Waits for 1.92us => 48 Cycles
			//////////////////////////////////////////////////////////*/
			`STATE_BACK_PORCH_HSYNC:
				begin
					oVSync = 1;
					oHSync = 1;
					Column_reset = 1;
					if (rTimeCount < 32'd48  )
						begin
							rNextState = `STATE_BACK_PORCH_HSYNC;
							rTimeCountReset = 0;
						end
					else 
						begin
							rNextState = `STATE_HSYNC;
							Column_reset = 1;
						end
				end
			/*//////////////////////////////////////////////////////////
				STATE_FRONT_PORCH_HSYNC:
					Waits for 640ns => 16 Cycles
			//////////////////////////////////////////////////////////*/
			`STATE_FRONT_PORCH_HSYNC:
				begin
					oVSync = 1;
					oHSync = 1;
					Column_reset = 1;
					if (rTimeCount < 32'd16  )
						begin
							rNextState = `STATE_FRONT_PORCH_HSYNC;
							rTimeCountReset = 0;
						end
					else 
						begin
							rNextState = `STATE_SEND_ROW;
							Column_reset = 1;
						end
				end
			/*//////////////////////////////////////////////////////////
				STATE_SEND_ROW:
					Sends a whole row (640 pixels). To the VGA display
			//////////////////////////////////////////////////////////*/
			`STATE_SEND_ROW:
				begin
					oVSync = 1;
					oHSync = 1;
					Column_reset = 0;
					if (rTimeCount < 32'd640  )
						begin
							rNextState = `STATE_FRONT_PORCH_HSYNC;
							rTimeCountReset = 0;
						end
					else 
						begin
							if(Row_index > 438) 
								begin	
									// Start all over from ROW 0
									rNextState = `STATE_BACK_PORCH_VSYNC;
									rTimeCountReset = 1;
								end
							else 
								begin
									// Move to next ROW
									rNextState = `STATE_FRONT_PORCH_HSYNC;
									rTimeCountReset = 1;
								end
						end
				end
		endcase
	end
 
