
`timescale 1ns / 1ps
`include "Defintions.v"
`define 	SIGUE1	7 
`define SIGUE 14 

module ROM
(
	input  wire[15:0]  		iAddress,
	output reg [27:0] 		oInstruction
);	
always @ ( iAddress )
begin
	case (iAddress)
	
	0: oInstruction = { `NOP ,	24'd4000	};
	1: oInstruction = { `STO , `R2, 16'd65000};
	2: oInstruction = { `STO , `R1, 16'd1};
	3: oInstruction = { `STO , `R7, 16'd5};
	4: oInstruction = { `STO , `R6, 16'd4};
	5: oInstruction = { `MUL , `R5, `R6, `R7 };
	6: oInstruction = { `LED ,	8'b0, `R5, 8'b0 };
	7: oInstruction = { `ADD , `R3, `R1, `R3};
	8: oInstruction = { `BLE , `SIGUE1, `R1, `R2};
	9: oInstruction = { `STO , `R7, 16'd5};
	10: oInstruction = { `STO , `R6, 16'd4};
	11: oInstruction = { `MUL , `R5, `R6, `R7 };
	12: oInstruction = { `LED ,	8'b0, `R5, 8'b0 };
	13: oInstruction = { `ADD , `R3, `R1, `R3};
	14: oInstruction = { `BLE , `SIGUE, `R1, `R2};
	15: oInstruction = { `SMUL , `R5, `R6, `R7 };


	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
