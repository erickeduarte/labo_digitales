
`timescale 1ns / 1ps
`include "Defintions.v"
`define COLS			8'b0 
`define ROWS 		8'b1 
`define ONE 			8'd2 
`define COLS_SIZE 	8'd3 
`define ROWS_SIZE	8'd4 
`define POSITIONX  	8'd5 
`define POSITIONY  	8'd6 
`define EVIL_X		8'd7 
`define EVIL_Y		8'd8 
`define COUNT    	8'd9 
`define MAX_COUNT	8'd10 
`define X_LIMIT		8'd11 
`define Y_LIMIT		8'd12 
`define SIZE			8'd13 
`define LED_DATA		8'd14 
`define X_MAX		8'd15 
`define Y_MAX		8'd16 
`define COUNT2		8'd11 
`define GREENLOOP 	8'd12 
`define 	LOOP2		8'd27 
`define 	DELAY		8'd34 
`define 	DELAY1 	8'd36 
`define 	DELAY2	8'd37 
`define	DECIDE		8'd41 
`define 	MOVE_EAST	8'd46 
`define 	LOOP2		8'd55 
`define 	MOVE_WEST	8'd62 
`define 	LOOP3		8'd71 
`define 	MOVE_NORTH	8'd78 
`define 	LOOP4		8'd87 
`define 	MOVE_SOUTH	8'd94 
`define 	LOOP2		8'd103 
`define		END			8'd110 

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
	5: oInstruction = { `STO , `ROWS_SIZE, 16'd99};
	6: oInstruction = { `STO , `MAX_COUNT, 16'd2000};
	7: oInstruction = { `STO , `SIZE, 16'd4};
	8: oInstruction = { `STO , `LED_DATA, 16'b1111111111111111};
	9: oInstruction = { `STO , `X_MAX, 16'd94};
	10: oInstruction = { `STO , `Y_MAX, 16'd94};
	11: oInstruction = { `NOP ,	24'd4000	};
	12: oInstruction = { `NOP ,	24'd4000	};
	13: oInstruction = { `VGA , `BLUE,5'b0 , `COLS, `ROWS  };
	14: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	15: oInstruction = { `BLE , `GREENLOOP, `COLS, `COLS_SIZE};
	16: oInstruction = { `STO , `COLS, 16'b0};
	17: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	18: oInstruction = { `BLE , `GREENLOOP, `ROWS, `ROWS_SIZE};
	19: oInstruction = { `STO , `POSITIONX, 16'd50}; //  Initial position 
	20: oInstruction = { `STO , `POSITIONY, 16'd50}; //  Initial position 
	21: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	22: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	23: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	24: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	25: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	26: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	27: oInstruction = { `VGA , `GREEN,5'b0 , `COLS, `ROWS  };
	28: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	29: oInstruction = { `BLE , `LOOP2, `COLS, `X_LIMIT};
	30: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	31: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	32: oInstruction = { `BLE , `LOOP2, `ROWS, `Y_LIMIT};
	33: oInstruction = { `JMP , `DECIDE, 16'b0 };
	34: oInstruction = { `STO , `COUNT, 16'b0};
	35: oInstruction = { `LED ,	8'b0, `LED_DATA, 8'b0 };
	36: oInstruction = { `STO , `COUNT2, 16'b0};
	37: oInstruction = { `ADD , `COUNT2, `ONE, `COUNT2};
	38: oInstruction = { `BLE , `DELAY2, `COUNT2, `MAX_COUNT};
	39: oInstruction = { `ADD , `COUNT, `ONE, `COUNT};
	40: oInstruction = { `BLE , `DELAY1, `COUNT, `MAX_COUNT};
	41: oInstruction = { `BEAST , `MOVE_EAST, 16'b0 };
	42: oInstruction = { `BSOUTH , `MOVE_SOUTH, 16'b0 };
	43: oInstruction = { `BNORTH , `MOVE_NORTH, 16'b0 };
	44: oInstruction = { `BWEST , `MOVE_WEST, 16'b0 };
	45: oInstruction = { `JMP , `DECIDE, 16'b0 };
	46: oInstruction = { `NOP ,	24'd4000	};
	47: oInstruction = { `BLE , `DELAY, `X_MAX, `POSITIONX};
	48: oInstruction = { `ADD , `POSITIONX, `POSITIONX, `SIZE};
	49: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	50: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	51: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	52: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	53: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	54: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	55: oInstruction = { `VGA , `GREEN,5'b0 , `COLS, `ROWS  };
	56: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	57: oInstruction = { `BLE , `LOOP2, `COLS, `X_LIMIT};
	58: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	59: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	60: oInstruction = { `BLE , `LOOP2, `ROWS, `Y_LIMIT};
	61: oInstruction = { `JMP , `DELAY, 16'b0 };
	62: oInstruction = { `NOP ,	24'd4000	};
	63: oInstruction = { `BLE , `DELAY, `POSITIONX, `ONE};
	64: oInstruction = { `SUB , `POSITIONX, `POSITIONX, `SIZE};
	65: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	66: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	67: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	68: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	69: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	70: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	71: oInstruction = { `VGA , `GREEN,5'b0 , `COLS, `ROWS  };
	72: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	73: oInstruction = { `BLE , `LOOP3, `COLS, `X_LIMIT};
	74: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	75: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	76: oInstruction = { `BLE , `LOOP3, `ROWS, `Y_LIMIT};
	77: oInstruction = { `JMP , `DELAY, 16'b0 };
	78: oInstruction = { `NOP ,	24'd4000	};
	79: oInstruction = { `BLE , `DELAY, `POSITIONY, `ONE};
	80: oInstruction = { `SUB , `POSITIONY, `POSITIONY, `SIZE};
	81: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	82: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	83: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	84: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	85: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	86: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	87: oInstruction = { `VGA , `GREEN,5'b0 , `COLS, `ROWS  };
	88: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	89: oInstruction = { `BLE , `LOOP4, `COLS, `X_LIMIT};
	90: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	91: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	92: oInstruction = { `BLE , `LOOP4, `ROWS, `Y_LIMIT};
	93: oInstruction = { `JMP , `DELAY, 16'b0 };
	94: oInstruction = { `NOP ,	24'd4000	};
	95: oInstruction = { `BLE , `DELAY, `X_MAX, `POSITIONY};
	96: oInstruction = { `ADD , `POSITIONY, `POSITIONY, `SIZE};
	97: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	98: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	99: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	100: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	101: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	102: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	103: oInstruction = { `VGA , `GREEN,5'b0 , `COLS, `ROWS  };
	104: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	105: oInstruction = { `BLE , `LOOP2, `COLS, `X_LIMIT};
	106: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	107: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	108: oInstruction = { `BLE , `LOOP2, `ROWS, `Y_LIMIT};
	109: oInstruction = { `JMP , `DELAY, 16'b0 };
	110: oInstruction = { `NOP ,	24'd4000	};
	111: oInstruction = { `JMP , `END, 16'b0 };


	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
