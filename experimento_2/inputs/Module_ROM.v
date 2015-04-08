
`timescale 1ns / 1ps
`include "Defintions.v"

module ROM
(
	input  wire[15:0]  		iAddress,
	output reg [27:0] 		oInstruction
);	
always @ ( iAddress )
begin
	case (iAddress)
	
	0: oInstruction = { `NOP ,	24'd4000	};
	1: oInstruction = { `STO , `R1, 16'd21896};
	2: oInstruction = { `STO , `R7, 16'd64677};
	3: oInstruction = { `LMUL , `R1, `R1, `R7 }; //  Multiplicacion de 8*5 


	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
