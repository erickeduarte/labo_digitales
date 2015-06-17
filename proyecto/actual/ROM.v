
`timescale 1ns / 1ps
`include "Defintions.v"
`define COLS		8'b0 
`define ROWS 	8'b1 
`define ONE 		8'd2 
`define MAX_ROWS 	8'd3 
`define MAX_COLS		8'd4 
`define STRIPE_SIZE  8'd5 
`define 	WHITELOOP	8'd6 
`define	END			8'd13 

module ROM
(
	input  wire[15:0]  		iAddress,
	output reg [27:0] 		oInstruction
);	
always @ ( iAddress )
begin
	case (iAddress)
	
	0: oInstruction = { `NOP ,	24'd4000	};
	1: oInstruction = { `STO , `COLS, 16'b0};
	2: oInstruction = { `STO , `ROWS, 16'b0};
	3: oInstruction = { `STO , `ONE, 16'b1};
	4: oInstruction = { `STO , `MAX_ROWS, 16'd99;};
	5: oInstruction = { `STO , `MAX_COLS, 16'd99;};
	6: oInstruction = { `NOP ,	24'd4000	};
	7: oInstruction = { `VGA , `WHITE,5'b0 , `COLS, `ROWS  };
	8: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	9: oInstruction = { `BLE , `WHITELOOP, `COLS, `MAX_COLS};
	10: oInstruction = { `STO , `COLS, 16'b0};
	11: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	12: oInstruction = { `BLE , `WHITELOOP, `ROWS, `MAX_ROWS};
	13: oInstruction = { `NOP ,	24'd4000	};
	14: oInstruction = { `JMP , `END, 16'b0 };


	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
