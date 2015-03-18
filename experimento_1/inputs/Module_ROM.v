`timescale 1ns / 1ps
`include "Defintions.v"

`define LOOP1 8'd8
`define LOOP2 8'd7
module ROM
(
	input  wire[15:0]  		iAddress,
	output reg [27:0] 		oInstruction
);	
always @ ( iAddress )
begin
	case (iAddress)

	0: oInstruction = { `NOP ,24'd4000    };
	1: oInstruction = { `STO , `R7,16'b0001 };
	2: oInstruction = { `STO ,`R3,16'h1     }; 
	3: oInstruction = { `STO, `R4,16'd1000 };
	4: oInstruction = { `STO, `R5,16'd0     }; 
	5: oInstruction = { `STO ,`R1,16'h0     }; 	
	6: oInstruction = { `STO ,`R2,16'd65000 }; //j
//LOOP2:
	7: oInstruction = { `LED ,8'b0,`R1,8'b0 };	
	
//LOOP1:	
	8: oInstruction = { `ADD ,`R1,`R1,`R3    };
	9: oInstruction = { `NOP ,24'd4000    };
	10: oInstruction = { `NOP ,24'd4000    };
	11: oInstruction = { `NOP ,24'd4000    };
	12: oInstruction = { `NOP ,24'd4000    };
	13: oInstruction = { `BLE ,`LOOP2,`R1,`R2 }; 
	14: oInstruction = { `JMP ,  8'd2,16'b0   };
	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
