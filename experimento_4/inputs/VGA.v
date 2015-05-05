module 
(
input  wire		  	clock,
output reg [19:0] 		oReadAddress
output	wire 			oVGA_Red,
output	wire 			oVGA_Green,
output	wire 			oVGA_Blue,
input 	wire [2:0]		wColorFromVideoMemory,
);	

wire 	[9:0] Column_index; 	// Counts from 0 to 640 
wire	[8:0] Row_index;		// Counts from 0 to 480
wire 	reset_row;
wire	reset_colum;

// Logi
always @ (posedge Clock) 
	begin
		// Increase Column index for each time
		if(reset_colum) 
			Row_index = 0;
		else if(Row_index > 680) 
			Row_index = 0;
		else 
			Row_index = Row_index + 1;
	end

// Read next signal
assign oReadAddress = Row_index*640+Column_index;
// Assign color ouputs
assign assign {oRed,oGreen,oBlue} = ( wCurrentRow < 100 || wCurrentRow > 540 || CurrentCol < 100 || CurrentCol > 380 ) : {0,0,0} : wColorFromVideoMemory;


endmodule
 
