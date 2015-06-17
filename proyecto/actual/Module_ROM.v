`timescale 1ns / 1ps
`include "Defintions.v"
`define COLS		8'b0 
`define ROWS 		8'b1 
`define ONE 		8'd2 
`define COLS_SIZE 	8'd3 
`define ROWS_SIZE	8'd4 
`define STRIPE_SIZE 8'd5 
`define GREENLOOP 	8'd7 
`define REDLOOP 	8'd15 
`define WHITELOOP	8'd23 
`define BLUELOOP 	8'd32 

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
	4: oInstruction = { `STO , `COLS_SIZE, 16'd99};
	5: oInstruction = { `STO , `ROWS_SIZE, 16'd24};
	6: oInstruction = { `STO , `STRIPE_SIZE, 16'd25};
	7: oInstruction = { `NOP ,	24'd4000	};
	8: oInstruction = { `VGA , `COLOR_GREEN,5'b0 , `COLS, `ROWS  };
	9: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	10: oInstruction = { `BLE , `GREENLOOP, `COLS, `COLS_SIZE};
	11: oInstruction = { `STO , `COLS, 16'b0};
	12: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	13: oInstruction = { `BLE , `GREENLOOP, `ROWS, `ROWS_SIZE};
	14: oInstruction = { `ADD , `ROWS_SIZE, `ROWS_SIZE, `STRIPE_SIZE};
	15: oInstruction = { `NOP ,	24'd4000	};
	16: oInstruction = { `VGA , `COLOR_RED,5'b0 , `COLS, `ROWS  };
	17: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	18: oInstruction = { `BLE , `REDLOOP, `COLS, `COLS_SIZE};
	19: oInstruction = { `STO , `COLS, 16'b0};
	20: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	21: oInstruction = { `BLE , `REDLOOP, `ROWS, `ROWS_SIZE};
	22: oInstruction = { `ADD , `ROWS_SIZE, `ROWS_SIZE, `STRIPE_SIZE};
	23: oInstruction = { `NOP ,	24'd4000	};
	24: oInstruction = { `VGA , `COLOR_BLUE,5'b0 , `COLS, `ROWS  };
	25: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	26: oInstruction = { `BLE , `WHITELOOP, `COLS, `COLS_SIZE};
	27: oInstruction = { `STO , `COLS, 16'b0};
	28: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	29: oInstruction = { `BLE , `WHITELOOP, `ROWS, `ROWS_SIZE};
	30: oInstruction = { `ADD , `ROWS_SIZE, `ROWS_SIZE, `STRIPE_SIZE};
	31: oInstruction = { `STO , `COLS, 16'b0};
//BLUELOOP	
	32: oInstruction = { `NOP ,	24'd4000	};
	33: oInstruction = { `VGA , `COLOR_WHITE,5'b0 , `COLS, `ROWS  };
	34: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	35: oInstruction = { `BLE , `BLUELOOP, `COLS, `COLS_SIZE};
	36: oInstruction = { `STO , `COLS, 16'b0};
	37: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	38: oInstruction = { `BLE , `BLUELOOP, `ROWS, `ROWS_SIZE};
	
	39: oInstruction = { `NOP ,	24'd4000	};
	40: oInstruction = { `JMP , 8'd39, 16'b0 };


	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
