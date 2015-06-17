`timescale 1ns / 1ps
`define STATE_RESET 0
`define STATE_POWERON_INIT_0 1
`define STATE_POWERON_INIT_1 2
`define STATE_POWERON_INIT_2 3
`define STATE_POWERON_INIT_3 4
`define STATE_POWERON_INIT_4 5
`define STATE_POWERON_INIT_5 6
`define STATE_POWERON_INIT_6 7
`define STATE_POWERON_INIT_7 8
`define STATE_POWERON_INIT_8 9
`define STATE_DISPLAY_CONFIG_0 10
`define STATE_DISPLAY_CONFIG_1 11
`define STATE_DISPLAY_CONFIG_2 12
`define STATE_DISPLAY_CONFIG_3 13
`define STATE_DISPLAY_CONFIG_4 14
`define STATE_DISPLAY_CONFIG_5 15
`define STATE_DISPLAY_CONFIG_6 16
`define STATE_DISPLAY_CONFIG_7 17
`define STATE_DISPLAY_CONFIG_8 18
`define STATE_DISPLAY_CONFIG_9 19
`define STATE_DISPLAY_CONFIG_10 20
`define STATE_DISPLAY_CONFIG_11 21
`define STATE_DISPLAY_CONFIG_12 22
`define STATE_DISPLAY_CONFIG_13 23
`define STATE_DISPLAY_CONFIG_14 24
`define STATE_DISPLAY_CONFIG_15 25
//`define STATE_DISPLAY_IDLE 26
`define STATE_DISPLAY_WRITE_0 27
`define STATE_DISPLAY_WRITE_1 28
`define STATE_DISPLAY_WRITE_2 29
`define STATE_DISPLAY_WRITE_3 30
`define STATE_DISPLAY_WRITE_4 31
`define STATE_DISPLAY_WRITE_5 32
`define STATE_DISPLAY_WRITE_6 33
`define STATE_DISPLAY_WRITE_7 34



//------------------------------------------------
module UPCOUNTER_POSEDGE # (parameter SIZE=16)
(
input wire Clock, Reset,
input wire [SIZE-1:0] Initial,
input wire Enable,
output reg [SIZE-1:0] Q
);


  always @(posedge Clock )
  begin
      if (Reset)
        Q = Initial;
      else
		begin
		if (Enable)
			Q = Q + 1;
			
		end			
  end

endmodule
//----------------------------------------------------
module mux (in0,in1,in2,in3, sel, out);
	input wire [7:0] in0,in1,in2,in3;
	input wire [1:0] sel;
	output reg [7:0] out;
	always @ (*)
		begin
			case (sel)
				0: out<=in0;
				1: out<=in1;
				2: out<=in2;
				3: out<=in3;
				default: out<=0;
			endcase
		end
endmodule
//----------------------------------------------------
module FFD_POSEDGE_SYNCRONOUS_RESET # ( parameter SIZE=8 )
(
	input wire				Clock,
	input wire				Reset,
	input wire				Enable,
	input wire [SIZE-1:0]	D,
	output reg [SIZE-1:0]	Q
);
	

always @ (posedge Clock) 
begin
	if ( Reset )
		Q <= 0;
	else
	begin	
		if (Enable) 
			Q <= D; 
	end	
 
end//always

endmodule


//----------------------------------------------------------------------

module FULL_ADDER  # (parameter SIZE=4)
(
	input wire[SIZE-1:0] wA,
	input wire[SIZE-1:0] wB,
	input wire wCi,
	output wire [SIZE-1:0] wR ,
	output wire wCo
);

	assign {wCo,wR} = wA + wB + wCi;
endmodule


//----------------------------------------------------------------------

module arrayMUL
(
	input wire [3:0] A,
	input wire [3:0] B,
	output reg [7:0] out
);

reg rC1, rC2, rC3; //registros para los llevos
reg [2:0] rT1, rT2; //registros temporales

always @ (*) begin

//R0
out[0] =A[0] & B[0];
//R1
{rC1, out[1]} = (A[0] & B[1]) + (A[1] & B[0]);
//R2
{rC1, rT1[0]} = (A[2] & B[0]) + (A[1] & B[1]) + rC1;
{rC2, out[2]} = (A[0] & B[2]) + rT1[0];
//R3
{rC1, rT1[1]} = (A[3] & B[0]) + (A[2] & B[1]) + rC1;
{rC2, rT2[0]} = (A[1] & B[2]) + rT1[1] + rC2;
{rC3, out[3]} = (A[0] & B[3]) + rT2[0];
//R4
{rC1, rT1[2]} = (A[3] & B[1]) + rC1;
{rC2, rT2[1]} = (A[2] & B[2]) + rT1[2] + rC2;
{rC3, out[4]} = (A[1] & B[3]) + rT2[1] + rC3;
//R5
{rC2, rT2[2]} = (A[3] & B[2]) + rC2 + rC1;
{rC3, out[5]} = (A[2] & B[3]) + rT2[2] + rC3;
//R6 y R7.
{out[7], out[6]} = (A[3] & B[3]) + rC2 + rC3;

end 
endmodule

//----------------------------------------------------------------------
module muxMUL (ia,ib,o);

	input wire [3:0] ib,ia;	
	output [7:0] o;

	wire [7:0] iaR,iaRA;
	wire [7:0] o0,o1;
	wire [7:0] o1R ;	
	
	assign iaR=ia<<1; // A desplazado0 una posicion a la izquierda
	assign iaRA=iaR+ia; // A desplazado una posicion a la izquierda mas A

	mux mux0 (.in0(8'b0),.in1({4'b0,ia}),.in2(iaR),.in3(iaRA),.sel({ib[1],ib[0]}),.out(o0)); 
	mux mux1 (.in0(8'b0),.in1({4'b0,ia}),.in2(iaR),.in3(iaRA),.sel({ib[3],ib[2]}),.out(o1)); 

	assign o1R=o1<<2; // Salida desplazada 2 posiciones a la izquierda

	assign o = o0+o1R; 
endmodule

//----------------------------------------------------------------------

module arrayMUL_GEN # (parameter SIZE = 16)(
input wire [SIZE-1:0] A,B,
output wire [(2*SIZE)-1:0] R
);

wire [(SIZE-2):0]  wCarry[SIZE:0];
wire [(SIZE-2):0] wResult[(SIZE-1):0];
wire [(SIZE-2):0] wInput1[(SIZE-1):0];
wire [(SIZE-2):0] wInput2[(SIZE-1):0];

assign wInput2[SIZE-1][0]= 1'b0;
genvar CurrentRow, CurrentCol;

generate
	for ( CurrentCol = 0; CurrentCol < (SIZE-1); CurrentCol = CurrentCol + 1)
		begin : MUL_COL
		for ( CurrentRow =0; CurrentRow < (SIZE-2); CurrentRow = CurrentRow + 1)
			begin : MUL_ROW
			assign wInput1[CurrentCol][CurrentRow]= A[CurrentCol] & B[CurrentRow+1];
			if(CurrentCol==0)
				begin 
					assign wCarry[0][CurrentRow]=1'b0;
				end
			if(CurrentRow==0 && CurrentCol!=SIZE-1)
				begin 
					assign wInput2[CurrentCol][0]= A[CurrentCol+1] & B[CurrentRow];
				end
			else if(CurrentCol==(SIZE-1))
				begin
					assign wInput2[CurrentCol][CurrentRow]=wCarry[CurrentCol +1][CurrentRow-1];
				end 
			else
				begin
					assign wInput2[CurrentCol][CurrentRow]= wResult[CurrentCol+1][CurrentRow-1];
				end	
				
			FULL_ADDER # (1) add
			(

				.wA(wInput1 [CurrentCol][CurrentRow]),

				.wB(wInput2[CurrentCol][CurrentRow]),

				.wCi(wCarry[CurrentCol][CurrentRow]),

				.wCo(wCarry[CurrentCol +1 ][CurrentRow]),
				.wR (wResult[CurrentCol][CurrentRow])
			);
		end
	end
endgenerate


wire wR0 = A[0] & B [0];
assign  R = {wResult[0], wR0};

endmodule

/*
module arrayMUL_GEN # (parameter SIZE = 4)(
	input wire [SIZE-1:0] A,B,
	output wire [(2*SIZE)-1:0] R
);

wire[(SIZE-1):0] wCarry[(SIZE-1):0];
//wire[(SIZE-1):0] iResult[(SIZE-1):0];
wire iResult[(SIZE-1):0]; 


assign R[0] = A[0] & B[0] ;
//genvar CurrentRow, CurrentCol;
genvar i,j;


wire[SIZE-1:0] twCi; //temporal para wCi
assign twCi[0] = 1'b0; 

generate
	for (i = 0; i <= 0; i = i + 1 )
	 begin
			for(j = 0; j < (SIZE-1); j = j +1 )
			begin
				
				if (j != 0)
					assign twCi[j] = wCarry[j-1][i];
				
				
				FULL_ADDER # (1) add
				(	
					.wA(A[j+1]&B[i]),
					.wB(A[j]&B[i+1]),
					.wCo(wCarry[j+1][i]),
					.wR(iResult[j+1]),
					.wCi(twCi[j])
				);
				end //for j
		end //for i		
endgenerate
//assign R = {wCarry[2][3],iResult[2][3],iResult[2][2],iResult[2][1],
		//	iResult[2][0],iResult[1][0],iResult[0][0], A[0]&B[0]};

endmodule
*/                                                         
//----------------------------------------------------------------------

module multiplicador4bits(
input wire [3:0] iMultiplicador,
input wire [7:0] iMultiplicando,
output reg [7:0] oResult );

always @(*)
case(iMultiplicador)
	0:oResult=0;
	1:oResult=iMultiplicando;
   2:oResult=iMultiplicando<<1;
	3:oResult=(iMultiplicando<<1) +iMultiplicando;
	4:oResult=(iMultiplicando<<2);
	5:oResult=(iMultiplicando<<2)+iMultiplicando;
	6:oResult=(iMultiplicando<<2)+(iMultiplicando<<1);
	7:oResult=(iMultiplicando<<2)+(iMultiplicando<<1)+iMultiplicando;
	8:oResult=iMultiplicando<<3;
	9:oResult=(iMultiplicando<<3)+iMultiplicando;
	10:oResult=(iMultiplicando<<3)+(iMultiplicando<<1);
	11:oResult=(iMultiplicando<<3)+(iMultiplicando<<1)+iMultiplicando;
   12:oResult=(iMultiplicando<<3)+(iMultiplicando<<2);
	13:oResult=(iMultiplicando<<3)+(iMultiplicando<<2)+ iMultiplicando;
  14:oResult=(iMultiplicando<<3)+(iMultiplicando<<2)+ (iMultiplicando<<1);
  15:oResult=(iMultiplicando<<3)+(iMultiplicando<<2)+ (iMultiplicando<<1) + iMultiplicando;

endcase
endmodule

module VGA_Controller_Josue #  ( parameter RESOL_X = 256, parameter RESOL_Y = 256)
(Clock25, Reset, iRGB, H_Sync, V_Sync, oRGB, Cont_X, Cont_Y);
   input  wire      Clock25, Reset;
   input  wire      [2:0] iRGB;// iColorCuadro;
   output wire 	  H_Sync, V_Sync;
   output wire	     [2:0] oRGB;
   output wire      [9:0] Cont_X, Cont_Y;


localparam FRAME_WIDTH_X = (270+48);	//Width + Front Porch
localparam FRAME_WIDTH_Y = (190+29);	//Width + Front Porch



wire iR, iG, iB;
wire oR, oG, oB;
wire [2:0] wMarco; //, wCuadro;
wire [2:0] wColorSelectionVGA;

assign wColorSelectionVGA = {iR, iG, iB};



assign iR = iRGB[2];
assign iG = iRGB[1];
assign iB = iRGB[0];
assign oRGB = {oR, oG, oB};

assign H_Sync = (Cont_X < 704) ? 1'b1 : 1'b0;
assign V_Sync = (Cont_Y < 519) ? 1'b1 : 1'b0;

//Marco negro con Imagen de 640*480
wire wNotInFrame;
assign wNotInFrame = ( 
								   (Cont_X < FRAME_WIDTH_X || Cont_X > FRAME_WIDTH_X + 100) //Not in X
								|| (Cont_Y < FRAME_WIDTH_Y || Cont_Y > FRAME_WIDTH_Y + 100)
							);

assign {oR, oG, oB} = wNotInFrame ?  3'b0 :  wColorSelectionVGA;
  
UPCOUNTER_POSEDGE # (10) HORIZONTAL_COUNTER
(
.Clock	(   Clock25   ), 
.Reset	( (Cont_X > 799) || Reset ),
.Initial	( 10'b0  ),
.Enable	(  1'b1	),
.Q			(	Cont_X  )
);

UPCOUNTER_POSEDGE # (10) VERTICAL_COUNTER
(
.Clock	( Clock25   ), 
.Reset	( (Cont_Y > 520) || Reset ),
.Initial	( 10'b0		),	
.Enable	( (Cont_X == 799) ? 1'b1:1'b0	),
.Q			( Cont_Y   )
);
   
endmodule


























module VGA_controller
  (
    input wire pixel_Clock, // 50 MHz
    input wire pixel_reset,
	 input wire pre_reset,
    output reg oVGA_HSYNC,
    output reg oVGA_VSYNC,
    output wire[2:0] oVGA_RGB
  );
	
	wire[9:0] wHorizontal_counter; 
	wire[9:0] wVertical_counter;
	
	
	assign oVGA_RGB = {1'b1, 1'b0, 1'b0 }; 
	reg fila_final, columna_final;

	//contadores de filas y columnas
	UPCOUNTER_POSEDGE # ( 10 ) contador_columnas (
		.Clock(   pixel_Clock ), 
		.Reset(   pixel_reset | columna_final ), // 
		.Initial( 10'b0  ),
		.Enable(  1'b1    ),
		.Q(       wHorizontal_counter)
	);

	UPCOUNTER_POSEDGE # ( 10 ) contador_filas (
		.Clock(   pixel_Clock ), 
		.Reset(   pixel_reset | fila_final ),
		.Initial( 10'b0  ),
		.Enable(  columna_final    ),
		.Q(       wVertical_counter)
	);
	
	always @ (posedge pixel_Clock)
	
		if(pixel_reset)
			begin
				columna_final <= 1'b0;
				fila_final <= 1'b0;
				oVGA_VSYNC = 1'b1;
				oVGA_HSYNC = 1'b1;
			end
		else
		begin

			//columnas
			if(wHorizontal_counter == 10'd481) //ultima columna 640+160 10'd799
				begin
					columna_final <= 1'b1;
					oVGA_HSYNC = 1'b1;
				end
			
			else if (wHorizontal_counter > 10'd16 && wHorizontal_counter < 10'd112 ) //655 & 751
				begin
					columna_final <= 1'b0;
					oVGA_HSYNC = 1'b0;
				end
			
			else
				begin
					columna_final <= 1'b0;
					oVGA_HSYNC = 1'b1;
				end
			
			//filas
			if(wVertical_counter == 10'd282) //521
				begin
					fila_final <= 1'b1;
					oVGA_VSYNC = 1'b1;
				end
			
			else if (wVertical_counter > 10'd10 && wVertical_counter < 10'd12 ) //490 & 492
				begin
					fila_final <= 1'b0;
					oVGA_VSYNC = 1'b0;
				end
			
			else
				begin
					fila_final <= 1'b0;
					oVGA_VSYNC = 1'b1;
				end		
		end
endmodule		

module shl
  (
	 input wire Clock,
    input wire [7:0] iRegistro,
    input wire [3:0] iBits_a_correr,
    output reg [7:0] oRegistro_corrido
  );
  always @(posedge Clock)
    case(iBits_a_correr)
      0: oRegistro_corrido <= iRegistro;
      1: oRegistro_corrido <= iRegistro << 1;
      2: oRegistro_corrido <= iRegistro << 2;
      3: oRegistro_corrido <= iRegistro << 3;
      4: oRegistro_corrido <= iRegistro << 4;
      5: oRegistro_corrido <= iRegistro << 5;
      6: oRegistro_corrido <= iRegistro << 6;
      7: oRegistro_corrido <= iRegistro << 7;
	endcase
endmodule

/////////////////////////////////////////
module VGA_controller_A7
(
	input wire				Clock_lento,
	input wire 				Reset,
	input wire  [2:0]		iVGA_RGB,
//	input wire  [2:0]		iColorCuadro,
//	input wire  [7:0]		iXRedCounter,
//	input wire  [7:0]		iYRedCounter,
	output wire [2:0]		oVGA_RGB,
	output wire				oHsync,
	output wire				oVsync,
	output wire [9:0]		oVcounter,
	output wire [9:0]		oHcounter
);
wire iVGA_R, iVGA_G, iVGA_B;
wire oVGA_R, oVGA_G, oVGA_B;
wire wEndline;
wire [3:0] wMarco; //, wCuadro;
//wire [2:0] wVGAOutputSelection;

assign wMarco = 3'b0;
//assign wCuadro = 3'b100;
//assign wVGAOutputSelection = ( ((oHcounter >= iXRedCounter + 10'd240) && (oHcounter <= iXRedCounter + 10'd240 + 10'd32)) &&
//										 ((oVcounter >= iYRedCounter + 10'd141) && (oVcounter <= iYRedCounter + 10'd141 + 8'd32))) ?
	//									iColorCuadro : {iVGA_R, iVGA_G, iVGA_B};

assign iVGA_R = iVGA_RGB[2];
assign iVGA_G = iVGA_RGB[1];
assign iVGA_B = iVGA_RGB[0];
assign oVGA_RGB = {oVGA_R, oVGA_G, oVGA_B};

assign oHsync = (oHcounter < 704) ? 1'b1 : 1'b0;
assign wEndline = (oHcounter == 799);
assign oVsync = (oVcounter < 519) ? 1'b1 : 1'b0;

// Marco negro e imagen de 256*256
//assign {oVGA_R, oVGA_G, oVGA_B} = (oVcounter < 141 || oVcounter >= 397 || 
					//  oHcounter < 240 || oHcounter > 496) ? 
					 // wMarco : wVGAOutputSelection;
assign {oVGA_R, oVGA_G, oVGA_B} = 3'b101;

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
