////////////////////////////////////////////////////////////////////////
/// MODULE:	VGA Controller 
////////////////////////////////////////////////////////////////////////
module VGA_Controller
(
input  	wire		  		Clock,
input  	wire		  		Reset,
output 	wire 	[15:0] 	oReadAddress,
output	wire 				oVGA_Red,
output	wire 				oVGA_Green,
output	wire 				oVGA_Blue,
input 	wire 	[2:0]		wColorFromVideoMemory,
output 	reg				oHSync,
output	reg				oVSync
);	


////////////////////////////////////////////////////////////////////////
/*
	Will be using 256*256 RAM. So ROW starts in 112 ends in (112+256=368). Else is black
	COLUMN starts in 192 ends in (192+256=448). Else is black
*/

wire 	Clock_25;
wire 	[8:0] Row_index;
wire 	[9:0] Column_index;
reg		Column_reset;
reg		Row_reset;

// Read next signal
assign oReadAddress = ( Row_index < 143 || Row_index > 399 || Column_index < 336 || Column_index > 592 ) ? 16'b0 : (Row_index-112)*256+(Column_index-192-96-48);
// Assign color ouputs
assign {oVGA_Red,oVGA_Green,oVGA_Blue} = ( Row_index < 112 || Row_index > 368 || Column_index < 336 || Column_index  > 592 ) ? 3'd7 : wColorFromVideoMemory;
////////////////////////////////////////////////////////////////////////

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
UPCOUNTER_POSEDGE #(10) COLUMN_COUNTER
(
	.Clock(Clock_25),
	.Reset(Column_reset),
	.Initial(10'b0),
	.Enable(1),
	.Q(Column_index)
);
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////.
//// ROW INDEX
UPCOUNTER_POSEDGE #(9) ROW_COUNTER
(
	.Clock(Column_reset),
	.Reset(Row_reset),
	.Initial(9'b0),
	.Enable(1),
	.Q(Row_index)
);
////////////////////////////////////////////////////////////////////////

///////////////////////////// RESET
always @ ( posedge Reset ) 
	begin
		oVSync = 1;
		oHSync = 1;
		Column_reset = 1;
		Row_reset = 1;
	end
/////////////////////////////	

///////////////////////////// ALL
always @ ( posedge Clock_25 )
	begin
		/// TPW VSYNC
		if (Row_index < 2)
			begin
				Row_reset = 0;
				oVSync = 0;
				oHSync = 1;
				if(Column_index < 96+48+640+16) 
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
				if(Column_index < 96+48+640+16) 
					begin	
						Column_reset = 0;
					end
				else 
					begin
						Column_reset = 1;
					end
			end
		// SEND COLUMNS
		else if (Row_index < 480+2+29) 
			begin
			Row_reset = 0;
				// TPW HSYNC
				if(Column_index < 96) 
					begin	
						oHSync = 0;
						oVSync = 1;
						Column_reset = 0;
					end
				// BACH PORCH HSYNC
				else if ( Column_index < 96+48+640+16) 
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

endmodule


