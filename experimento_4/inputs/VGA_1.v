////////////////////////////////////////////////////////////////////////
/// MODULE:	VGA Controller 
////////////////////////////////////////////////////////////////////////
module VGA_Controller
(
input  wire		  	Clock,
input  wire		  	Reset,
output reg [19:0] 		oReadAddress,
output	wire 			oVGA_Red,
output	wire 			oVGA_Green,
output	wire 			oVGA_Blue,
input 	wire [2:0]		wColorFromVideoMemory,
output reg				oHSync,
output	reg				oVSync
);	


////////////////////////////////////////////////////////////////////////
/*
	Will be using 256*256 RAM. So ROW starts in 112 ends in (112+256=368). Else is black
	COLUMN starts in 192 ends in (192+256=448). Else is black
*/
// Read next signal
//assign oReadAddress = ( wCurrentRow < 143 || wCurrentRow > 399 || CurrentCol < 336 || CurrentCol > 592 ) : 0 : (Row_index-112)*256+(Column_index-192-96-48);
// Assign color ouputs
//assign {oRed,oGreen,oBlue} = ( wCurrentRow < 112 || wCurrentRow > 368 || CurrentCol < 336 || CurrentCol > 592 ) : {0,0,0} : wColorFromVideoMemory;
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
wire 	Clock_25;
wire 	[8:0] Row_index;
wire 	[9:0] Column_index;
reg		Column_reset;
reg		Row_reset;
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
UPCOUNTER_POSEDGE #(1) Clock_25MHz
(
	.Clock(Clock),
	.Reset(Reset),
	.Initial(0),
	.Enable(1),
	.Q(Clock_25)
);
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////.
//// COLUMN INDEX
UPCOUNTER_POSEDGE #(10) COLUMN_COUNTER
(
	.Clock(Clock_25),
	.Reset(Column_reset | Reset),
	.Initial(8'b0),
	.Enable(1),
	.Q(Column_index)
);
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////.
//// ROW INDEX
UPCOUNTER_POSEDGE #(9) ROW_COUNTER
(
	.Clock(Column_reset),
	.Reset(Row_reset | Reset),
	.Initial(9'b0),
	.Enable(1),
	.Q(Column_index)
);
////////////////////////////////////////////////////////////////////////
always @ ( posedge Clock_25 )
	begin
		/// TPW VSYNC
		if (Row_index < 2)
			begin
				VSync = 0;
				HSync = 1;
				if(Column_index < 96+48+640+16) 
					begin	
						Column_reset = 0;
					end
				else 
					begin
						HSync = 1;
						VSync = 1;
						Column_reset = 1;
					end
			end
		/// BACK PORCH
		else if (Row_index < 2+29)
			begin
				VSync = 1;
				HSync = 1;
				if(Column_index < 96+48+640+16) 
					begin	
						Column_reset = 0;
					end
				else 
					begin
						HSync = 1;
						VSync = 1;
						Column_reset = 1;
					end
			end
		// SEND COLUMNS
		else if (Row_index < 480+2+29) 
			begin
				// TPW HSYNC
				if(Column_index < 96) 
					begin	
						HSync = 0;
						VSync = 1;
						Column_reset = 0;
					end
				// BACH PORCH HSYNC
				else if ( Column_index < 96+48+640+16) 
					begin	
						HSync = 1;
						VSync = 1;
						Column_reset = 0;
					end
				// SEND COLUMNS
				else 
					begin
						HSync = 1;
						VSync = 1;
						Column_reset = 1;
					end
			end
		/// FRONT PORCH VSYNC
		else if (Row_index < 480+10+2+29)
			begin
				HSync = 1;
				VSync = 1;
				
				if(Column_index < 96+48+640+16) 
					begin	
						Column_reset = 0;
					end
				else 
					begin
						HSync = 1;
						VSync = 1;
						Column_reset = 1;
					end
			end
				
	end
//----------------------------------------------------------------------//
