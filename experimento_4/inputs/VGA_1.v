////////////////////////////////////////////////////////////////////////
/// MODULE:	VGA Controller 
////////////////////////////////////////////////////////////////////////
module VGA_Controller
(
	input  	wire		  		Clock,
	input  	wire		  		Reset,					
	output 	wire 	[15:0] 	oReadAddress,			// Input adress to VGA RAM
	output	wire 				oVGA_Red,				// Color RED
	output	wire 				oVGA_Green,				// Color GREEN
	output	wire 				oVGA_Blue,				// Color BLUE
	input 	wire 	[2:0]		wColorFromVideoMemory,	// Color received from VGA RAM
	output 	wire				oHSync,					// Horizontal Sync
	output	wire				oVSync					// Vertical Sync
);	


////////////////////////////////////////////////////////////////////////
/*
	Will be using 256*256 RAM. So ROW starts in 112 ends in (112+256=368). Else is black
	COLUMN starts in 192 ends in (192+256=448). Else is black
*/ 

wire 	Clock_25;
wire 	[9:0] Row_index;
wire 	[9:0] Column_index;
wire			Column_reset;
wire			Row_reset;

// Read next signal
//assign oReadAddress = ( Row_index < 143 || Row_index > 399 || Column_index < 336 || Column_index > 592 ) ? 16'b0 : (Row_index-143)*256+(Column_index-396);
assign oReadAddress = ( Row_index < 141 || Row_index > 396 || Column_index < 240 || Column_index > 496 ) ? 16'b0 : (Row_index-143)*256+(Column_index-396);
// Assign color ouputs
// assign {oVGA_Red,oVGA_Green,oVGA_Blue} = ( Row_index < 112 || Row_index > 368 || Column_index < 336 || Column_index  > 592 ) ? 3'b101 : wColorFromVideoMemory;
assign {oVGA_Red,oVGA_Green,oVGA_Blue} = 3'b100;

////////////////////////////////////////////////////////////////////////
wire enable;
////////////////////////////////////////////////////////////////////////


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
UPCOUNTER_POSEDGE # (10) HORIZONTAL_COUNTER
(
.Clock	(   Clock_25   ), 
.Reset	( (Column_index > 799) || Reset ),
.Initial	( 10'b0  ),
.Enable	(  1'b1	),
.Q			(	Column_index  )
);

UPCOUNTER_POSEDGE # (10) VERTICAL_COUNTER
(
.Clock	( Clock_25   ), 
.Reset	( (Row_index > 520) || Reset ),
.Initial	( 10'b0		),	
.Enable	( (Column_index == 799) ? 1'b1:1'b0	),
.Q			( Row_index   )
);
////////////////////////////////////////////////////////////////////////
assign oHSync = (Column_index < 704) ? 1'b1 : 1'b0;
assign oVSync = (Row_index < 519) ? 1'b1 : 1'b0;
/*
assign enable = (Column_index == 799);
// Reset signals when they reach maximun
assign Row_reset = (Row_index > 520) || Reset;
assign Column_reset = (Column_index > 799) || Reset;
// Syncs
assign oVSync = (Row_index < 519)?1'b1:1'b0; 
assign oHSync = (Column_index < 704)?1'b1:1'b0; 
*/

/*
always @ ( posedge Clock_25 or posedge Reset)	
	/// RESET
	if(Reset)
		begin 
			oVSync = 1;
			oHSync = 1;
			Column_reset = 1;
			Row_reset = 1;
		end
	else 
		begin
			/// TPW VSYNC
			if (Row_index < 2)
				begin
					Row_reset = 0;
					oVSync = 0; // Active VSync
					oHSync = 1;
					if(Column_index < 800) 
						begin	
							Column_reset = 0;
						end
					else 
						begin
							Column_reset = 1;
						end
				end
			/// BACK PORCH
			else if (Row_index < 2+29)
				begin
					Row_reset = 0;
					oVSync = 1;
					oHSync = 1;
					if(Column_index < 800) 
						begin	
							Column_reset = 0;
						end
					else 
						begin
							Column_reset = 1;
						end
				end
			// -------------------------------------------
			// SEND COLUMNS
			else if (Row_index < 480+2+29) 
				begin
					Row_reset = 0;
					// TPW HSYNC
					if(Column_index < 96) 
						begin	
							oHSync = (Row_index == 31) ? 1:0; // Active oHSync
							oVSync = 1;
							Column_reset = 0;
						end
					// BACH PORCH HSYNC
					else if ( Column_index < 800) 
						begin	
							oHSync = 1;
							oVSync = 1;
							Column_reset = 0;
						end
					// SEND COLUMNS
					else 
						begin
							oHSync = 1;
							oVSync = 1;
							Column_reset = 1;
						end
				end
			// -------------------------------------------
			/// FRONT PORCH VSYNC
			else if (Row_index < 480+10+2+29)
				begin
					oHSync = 1;
					oVSync = 1;
					
					if(Column_index < 96+48+640+16) 
						begin	
							Column_reset = 0;
							Row_reset = 0;
						end
					else 
						begin
							Column_reset = 1;
							Row_reset = 1;
						end
				end
					
		end
//----------------------------------------------------------------------//
*/
endmodule


