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
	
	0: oInstruction = { `STO , 8'b1, 16'hffff};
	1: oInstruction = { `NOP ,	24'd4000	};
	2: oInstruction = { `LED ,	8'b0, 8'b1, 8'b0 };
	3: oInstruction = { `NOP ,	24'd4000	};
	4: oInstruction = { `BNLCD , 8'd4, 16'b0  }; //  	Loop untill LCD display is ready 
	5: oInstruction = { `LCD , 8'd0 , 8'b01001000, 8'b0  }; // 	H is 01001000 -- Write to LCD 
	6: oInstruction = { `NOP ,	24'd4000	};
	7: oInstruction = { `BNLCD , 8'd6, 16'b0  }; // 	Loop untill LCD display is ready 
	8: oInstruction = { `LCD , 8'd0 , 8'b01001111, 8'b0  }; // 	O is 01001111-- Write to LCD 
	9: oInstruction = { `NOP ,	24'd4000	};
	10: oInstruction = { `BNLCD , 8'd9, 16'b0  }; // 	Loop untill LCD display is ready 
	11: oInstruction = { `LCD , 8'd0 , 8'b01001100, 8'b0  }; // 	L is 01001110 -- Write to LCD 
	12: oInstruction = { `NOP ,	24'd4000	};
	13: oInstruction = { `BNLCD , 8'd12, 16'b0  }; // 	Loop untill LCD display is ready 
	14: oInstruction = { `LCD , 8'd0 , 8'b01000001, 8'b0  }; // 	A is 01000001 -- Write to LCD 
	15: oInstruction = { `NOP ,	24'd4000	};
	16: oInstruction = { `BNLCD , 8'd15, 16'b0  }; //  	Loop untill LCD display is ready 
	17: oInstruction = { `LCD , 8'd0 , 8'b00100000, 8'b0  }; // 	SPACE is 00100000 -- Write to LCD 
	18: oInstruction = { `NOP ,	24'd4000	};
	19: oInstruction = { `BNLCD , 8'd18, 16'b0  }; //  	Loop untill LCD display is ready 
	20: oInstruction = { `LCD , 8'd0 , 8'b01001101, 8'b0  }; // 	M is 01001101 -- Write to LCD 
	21: oInstruction = { `NOP ,	24'd4000	};
	22: oInstruction = { `BNLCD , 8'd21, 16'b0  }; //  	Loop untill LCD display is ready 
	23: oInstruction = { `LCD , 8'd0 , 8'b01010101, 8'b0  }; // 	U is 01010101 -- Write to LCD 
	24: oInstruction = { `NOP ,	24'd4000	};
	25: oInstruction = { `BNLCD , 8'd24, 16'b0  }; //  	Loop untill LCD display is ready 
	26: oInstruction = { `LCD , 8'd0 , 8'b01001110, 8'b0  }; // 	N is 01001110 -- Write to LCD 
	27: oInstruction = { `NOP ,	24'd4000	};
	28: oInstruction = { `BNLCD , 8'd27, 16'b0  }; //  	Loop untill LCD display is ready 
	29: oInstruction = { `LCD , 8'd0 , 8'b01000100, 8'b0  }; // 	D is 01000100 -- Write to LCD 
	30: oInstruction = { `NOP ,	24'd4000	};
	31: oInstruction = { `BNLCD , 8'd30, 16'b0  }; //  	Loop untill LCD display is ready 
	32: oInstruction = { `LCD , 8'd0 , 8'b01001111, 8'b0  }; // 	O is 01001111 -- Write to LCD 
	33: oInstruction = { `NOP ,	24'd4000	};
	34: oInstruction = { `BNLCD , 8'd33, 16'b0  }; //  	Loop untill LCD display is ready 
	35: oInstruction = { `LCD , 8'd0 , 8'b00100001, 8'b0  }; // 	! is 00100001 -- Write to LCD 
	36: oInstruction = { `NOP ,	24'd4000	};
	37: oInstruction = { `JMP , 8'd36, 16'b0 };


	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
