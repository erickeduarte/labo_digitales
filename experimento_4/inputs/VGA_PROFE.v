//----------------------------------------------------------------------
// Módulo VGA controller
module VGA_controller
(
	input wire					Clock,
	input wire 				Reset,
	output wire	[2:0]		oVGA_RGB,
	output wire				oHsync,
	output wire				oVsync,
	output wire 	[9:0]		oVcounter,
	output wire 	[9:0]		oHcounter
);
wire iVGA_R, iVGA_G, iVGA_B;
wire oVGA_R, oVGA_G, oVGA_B;
wire wEndline;
wire [3:0] wMarco; //, wCuadro;
wire [2:0] wVGAOutputSelection;

//////////////////////////////////
UPCOUNTER_POSEDGE #(1) Clock_25MHz
(
	.Clock(Clock),
	.Reset(Reset),
	.Initial(0),
	.Enable(1),
	.Q(Clock_lento)
);

assign wMarco = 3'b101;
//assign wCuadro = 3'b100;
assign wVGAOutputSelection = ( ((oHcounter >= iXRedCounter + 10'd240) && (oHcounter <= iXRedCounter + 10'd240 + 10'd32)) &&
										 ((oVcounter >= iYRedCounter + 10'd141) && (oVcounter <= iYRedCounter + 10'd141 + 8'd32))) ?
										iColorCuadro : {iVGA_R, iVGA_G, iVGA_B};


assign oVGA_RGB = {oVGA_R, oVGA_G, oVGA_B};

assign oHsync = (oHcounter < 704) ? 1'b1 : 1'b0;
assign wEndline = (oHcounter == 799);
assign oVsync = (oVcounter < 519) ? 1'b1 : 1'b0;
/*
// Marco negro e imagen de 256*256
 //assign {oVGA_R, oVGA_G, oVGA_B} = (oVcounter < 141 || oVcounter >= 397 || 
					  oHcounter < 240 || oHcounter > 496) ? 
					  wMarco : wVGAOutputSelection;
*/
assign {oVGA_R, oVGA_G, oVGA_B} = 3'b111;

UPCOUNTER_POSEDGE # (10) HORIZONTAL_COUNTER
(
.Clock	(   Clock_lento   ), 
.Reset	( (oHcounter > 799) || Reset 		),
.Initial	( 10'b0  			),
.Enable	(  1'b1				),
.Q			(	oHcounter      )
);

UPCOUNTER_POSEDGE # (10) VERTICAL_COUNTER
(
.Clock	( Clock_lento    ), 
.Reset	( (oVcounter > 520) || Reset ),
.Initial	( 10'b0  			),	
.Enable	( wEndline            ),
.Q			( oVcounter      )
);

endmodule
