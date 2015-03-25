`timescale 1ns / 1ps
`include "Defintions.v"

`define NUM1 8'd0 
`define NUM2 8'd1 
`define LOOP1 8'd3 

module ROM
(
	input  wire[15:0]  		iAddress,
	output reg [27:0] 		oInstruction
);	

always @ ( iAddress )
begin
	case (iAddress)
	0: oInstruction = { `STO , `NUM1, 16'b0};
	1: oInstruction = { `STO , `NUM2, 16'b1};
	2: oInstruction = { `STO , `NUM1, 16'b0};
	3: oInstruction = { `NOP ,	24'd0000	};
	4: oInstruction = { `ADD , `NUM1, `NUM2, `NUM1}; //  Suma de NUM1 y NUM2 en NUM1 
	5: oInstruction = { `ADD , `NUM1, `NUM2, `NUM1}; //  Misma operación 
	6: oInstruction = { `ADD , `NUM1, `NUM2, `NUM1}; //  Misma operación 
	7: oInstruction = { `JMP , `LOOP1, 16'd0 };




	
	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
