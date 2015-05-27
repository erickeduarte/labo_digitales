module VGA_Controller (Clock, Reset, H_Sync, V_Sync, oRGB, Cont_X, Cont_Y);
   input  wire      Clock, Reset;
   output wire 	H_Sync, V_Sync;
   output wire		[2:0] oRGB;
   output wire		[9:0] Cont_X, Cont_Y;

localparam RGB_MARCO = 3'b0;
localparam MARCO_X = 48;
localparam MARCO_Y = 32;
localparam MARCO = 3'b010;

localparam RESOL_X = 640;
localparam RESOL_Y = 480;
localparam NUM_CUADROS_X = 16;
localparam NUM_CUADROS_Y = 16;

wire Clock25 = Cont_X[0];

wire iR, iG, iB;
wire oR, oG, oB;
wire [2:0] wMarco; //, wCuadro;

/*
assign wColorSelectionVGA = (((Cont_X >= (iPosicionX*(RESOL_X/NUM_CUADROS_X)) + MARCO_X) && (Cont_X <= (iPosicionX*(RESOL_X/NUM_CUADROS_X)) + (RESOL_X/NUM_CUADROS_X) + MARCO_X)) &&
										 ((Cont_Y >= (iPosicionY*(RESOL_Y/NUM_CUADROS_Y) + MARCO_Y)) && (Cont_Y <= (iPosicionY*(RESOL_Y/NUM_CUADROS_Y)) + (RESOL_Y/NUM_CUADROS_Y) + MARCO_Y))) ?
										iColorCuadro : {iR, iG, iB}; */ 

///assign wColorSelectionVGA = {iR, iG, iB};

assign iR = iRGB[2];
assign iG = iRGB[1];
assign iB = iRGB[0];
assign oRGB = {oR, oG, oB};

assign H_Sync = (Cont_X < 704) ? 1'b1 : 1'b0;
assign V_Sync = (Cont_Y < 519) ? 1'b1 : 1'b0;

//Marco negro con Imagen de 640*480
assign {oR, oG, oB} = (Cont_Y < MARCO_Y || Cont_Y >= RESOL_Y+MARCO_Y || Cont_X < MARCO_X || Cont_X > RESOL_X+MARCO_X) ?  MARCO : 3'b101;

UPCOUNTER_POSEDGE # (10) HORIZONTAL_COUNTER
(
.Clock		(   Clock25   ), 
.Reset		( (Cont_X > 799) || Reset ),
.Initial	( 10'b0  ),
.Enable		(  1'b1	 ),
.Q			(	Cont_X  )
);

UPCOUNTER_POSEDGE # (10) VERTICAL_COUNTER
(
.Clock		( Clock25   ), 
.Reset		( (Cont_Y > 520) || Reset ),
.Initial	( 10'b0		),	
.Enable		( (Cont_X == 799) ? 1'b1:1'b0 ),
.Q			( Cont_Y    )
);
   
endmodule
