
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
	
	0: oInstruction = { `STO , 8'b1, 16'bffff};
	1: oInstruction = { `NOP ,	24'd4000	};
	2: oInstruction = { `LED ,	8'b0, 8'b1, 8'b0 };
	3: oInstruction = { `NOP ,	24'd4000	};
	4: oInstruction = { `BNLCD , 8'b0, 16'b0  }; //  	Loop untill LCD display is ready 
	5: oInstruction = { `LCD , 8'd0 , 8'b01001000, 8'b0  }; // 	H is 01001000 -- Write to LCD 
	6: oInstruction = { `NOP ,	24'd4000	};
	7: oInstruction = { `BNLCD , 8'd3, 16'b0  }; // 	Loop untill LCD display is ready 
	8: oInstruction = { `LCD , 8'd0 , 8'b01001111, 8'b0  }; // 	O is 01001111-- Write to LCD 
	9: oInstruction = { `NOP ,	24'd4000	};
	10: oInstruction = { `BNLCD , 8'd6, 16'b0  }; // 	Loop untill LCD display is ready 
	11: oInstruction = { `LCD , 8'd0 , 8'b01001100, 8'b0  }; // 	L is 01001110 -- Write to LCD 
	12: oInstruction = { `NOP ,	24'd4000	};
	13: oInstruction = { `BNLCD , 8'd9, 16'b0  }; // 	Loop untill LCD display is ready 
	14: oInstruction = { `LCD , 8'd0 , 8'b01000001, 8'b0  }; // 	A is 01000001 -- Write to LCD 
	15: oInstruction = { `NOP ,	24'd4000	};
	16: oInstruction = { `JMP , 8'd12, 16'b0 };


	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
