
`timescale 1ns / 1ps
`include "Defintions.v"
`define COLS 8'b0 
`define ROWS 8'b1 
`define ONE 8'd2 
`define GREENLOOP 8'd4 
`define REDLOOP 8'd10 
`define WHITELOOP 8'd16 
`define BLUELOOP 8'd22 

module ROM
(
	input  wire[15:0]  		iAddress,
	output reg [27:0] 		oInstruction
);	
always @ ( iAddress )
begin
	case (iAddress)
	
	0: oInstruction = { `NOP ,	24'd4000	};
/*	1: oInstruction = { `STO , `COLS, 16'b0};
	2: oInstruction = { `STO , `ROWS, 16'b0};
	3: oInstruction = { `STO , `ONE, 16'b1};
	4: oInstruction = { `NOP ,	24'd4000	};
	5: oInstruction = { `VGA , `COLOR_GREEN,5'b0 , `COLS, `ROWS  };
	6: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	7: oInstruction = { `BLE , `GREENLOOP, `COLS, 8'd255};
	8: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	9: oInstruction = { `BLE , `GREENLOOP, `ROWS, 8'd63};
	10: oInstruction = { `NOP ,	24'd4000	};
	11: oInstruction = { `VGA , `COLOR_RED,5'b0 , `COLS, `ROWS  };
	12: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	13: oInstruction = { `BLE , `REDLOOP, `COLS, 8'd255};
	14: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	15: oInstruction = { `BLE , `REDLOOP, `ROWS, 8'd127};
	16: oInstruction = { `NOP ,	24'd4000	};
	17: oInstruction = { `VGA , `COLOR_RED,5'b0 , `COLS, `ROWS  };
	18: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	19: oInstruction = { `BLE , `WHITELOOP, `COLS, 8'd255};
	20: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	21: oInstruction = { `BLE , `WHITELOOP, `ROWS, 8'd191};
	22: oInstruction = { `NOP ,	24'd4000	};
	23: oInstruction = { `VGA , `COLOR_RED,5'b0 , `COLS, `ROWS  };
	24: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	25: oInstruction = { `BLE , `BLUELOOP, `COLS, 8'd255};
	26: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	27: oInstruction = { `BLE , `BLUELOOP, `ROWS, 8'd255};
	28: oInstruction = { `NOP ,	24'd4000	};
	29: oInstruction = { `JMP , 8'd28, 16'b0 };
*/

	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
