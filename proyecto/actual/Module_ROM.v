
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
`define INIT_LOOP 	8'd12 
`define 	INIT_EVIL	8'd27 
`define 	PLYR_INIT		8'd41 
`define 	DELAY		8'd47 
`define 	DELAY1 	8'd49 
`define 	DELAY2	8'd50 
`define 	CLOSE_X		8'd60 
`define 	MOVE_EAST	8'd62 
`define 	DEL_EAST	8'd70 
`define 	DRW_EAST	8'd83 
`define 	MOVE_WEST	8'd90 
`define 	DEL_WEST	8'd98 
`define 	DRW_WEST		8'd111 
`define 	MOVE_NORTH	8'd118 
`define 	DEL_NORTH	8'd126 
`define 	DRW_NORTH		8'd139 
`define 	MOVE_SOUTH	8'd146 
`define 	DEL_SOUTH	8'd154 
`define 	DRW_SOUTH		8'd167 
`define EVIL_MOVE	8'd174 
`define 	DEL_EVIL	8'd181 
`define	EVL_RIGHT	8'd190 
`define 	DECIDE_Y	8'd191 
`define	EVL_DOWN	8'd194 
`define 	PAINT_EVIL	8'd195 
`define 	DRW_EVIL		8'd201 
`define GAME_OVER	8'd208 
`define END_LOOP 	8'd210 
`define		END			8'd217 

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
	8: oInstruction = { `STO , `LED_DATA, 16'b0101};
	9: oInstruction = { `STO , `X_MAX, 16'd94};
	10: oInstruction = { `STO , `Y_MAX, 16'd94};
	11: oInstruction = { `NOP ,	24'd4000	};
	12: oInstruction = { `NOP ,	24'd4000	};
	13: oInstruction = { `VGA , `BLUE,5'b0 , `COLS, `ROWS  };
	14: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	15: oInstruction = { `BLE , `INIT_LOOP, `COLS, `COLS_SIZE};
	16: oInstruction = { `STO , `COLS, 16'b0};
	17: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	18: oInstruction = { `BLE , `INIT_LOOP, `ROWS, `ROWS_SIZE};
	19: oInstruction = { `STO , `EVIL_X, 16'd02}; //  Initial position EVILX 
	20: oInstruction = { `STO , `EVIL_Y, 16'd02}; //  Initial position	EVILY 
	21: oInstruction = { `CPY , `COLS, `EVIL_X, `EVIL_X };
	22: oInstruction = { `CPY , `ROWS, `EVIL_Y, `EVIL_Y };
	23: oInstruction = { `CPY , `X_LIMIT, `EVIL_X, `EVIL_X };
	24: oInstruction = { `CPY , `Y_LIMIT, `EVIL_Y, `EVIL_Y };
	25: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	26: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	27: oInstruction = { `VGA , `RED,5'b0 , `COLS, `ROWS  };
	28: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	29: oInstruction = { `BLE , `INIT_EVIL, `COLS, `X_LIMIT};
	30: oInstruction = { `CPY , `COLS, `EVIL_X, `EVIL_X };
	31: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	32: oInstruction = { `BLE , `INIT_EVIL, `ROWS, `Y_LIMIT};
	33: oInstruction = { `STO , `POSITIONX, 16'd50}; //  Initial position 
	34: oInstruction = { `STO , `POSITIONY, 16'd50}; //  Initial position 
	35: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	36: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	37: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	38: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	39: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	40: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	41: oInstruction = { `VGA , `GREEN,5'b0 , `COLS, `ROWS  };
	42: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	43: oInstruction = { `BLE , `PLYR_INIT, `COLS, `X_LIMIT};
	44: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	45: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	46: oInstruction = { `BLE , `PLYR_INIT, `ROWS, `Y_LIMIT};
	47: oInstruction = { `STO , `COUNT, 16'b0};
	48: oInstruction = { `LED ,	8'b0, `LED_DATA, 8'b0 };
	49: oInstruction = { `STO , `COUNT2, 16'b0};
	50: oInstruction = { `ADD , `COUNT2, `ONE, `COUNT2};
	51: oInstruction = { `BLE , `DELAY2, `COUNT2, `MAX_COUNT};
	52: oInstruction = { `ADD , `COUNT, `ONE, `COUNT};
	53: oInstruction = { `BLE , `DELAY1, `COUNT, `MAX_COUNT};
	54: oInstruction = { `BEAST , `MOVE_EAST, 16'b0 };
	55: oInstruction = { `BSOUTH , `MOVE_SOUTH, 16'b0 };
	56: oInstruction = { `BNORTH , `MOVE_NORTH, 16'b0 };
	57: oInstruction = { `BWEST , `MOVE_WEST, 16'b0 };
	58: oInstruction = { `BCLOSE , `CLOSE_X, `POSITIONX, `EVIL_X };
	59: oInstruction = { `JMP , `DELAY, 16'b0 };
	60: oInstruction = { `BCLOSE , `GAME_OVER, `POSITIONY, `EVIL_Y };
	61: oInstruction = { `JMP , `DELAY, 16'b0 };
	62: oInstruction = { `NOP ,	24'd4000	};
	63: oInstruction = { `BLE , `DELAY, `X_MAX, `POSITIONX};
	64: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	65: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	66: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	67: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	68: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	69: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	70: oInstruction = { `VGA , `BLUE,5'b0 , `COLS, `ROWS  };
	71: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	72: oInstruction = { `BLE , `DEL_EAST, `COLS, `X_LIMIT};
	73: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	74: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	75: oInstruction = { `BLE , `DEL_EAST, `ROWS, `Y_LIMIT};
	76: oInstruction = { `ADD , `POSITIONX, `POSITIONX, `SIZE};
	77: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	78: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	79: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	80: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	81: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	82: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	83: oInstruction = { `VGA , `GREEN,5'b0 , `COLS, `ROWS  };
	84: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	85: oInstruction = { `BLE , `DRW_EAST, `COLS, `X_LIMIT};
	86: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	87: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	88: oInstruction = { `BLE , `DRW_EAST, `ROWS, `Y_LIMIT};
	89: oInstruction = { `JMP , `EVIL_MOVE, 16'b0 };
	90: oInstruction = { `NOP ,	24'd4000	};
	91: oInstruction = { `BLE , `DELAY, `POSITIONX, `LED_DATA};
	92: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	93: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	94: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	95: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	96: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	97: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	98: oInstruction = { `VGA , `BLUE,5'b0 , `COLS, `ROWS  };
	99: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	100: oInstruction = { `BLE , `DEL_WEST, `COLS, `X_LIMIT};
	101: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	102: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	103: oInstruction = { `BLE , `DEL_WEST, `ROWS, `Y_LIMIT};
	104: oInstruction = { `SUB , `POSITIONX, `POSITIONX, `SIZE};
	105: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	106: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	107: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	108: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	109: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	110: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	111: oInstruction = { `VGA , `GREEN,5'b0 , `COLS, `ROWS  };
	112: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	113: oInstruction = { `BLE , `DRW_WEST, `COLS, `X_LIMIT};
	114: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	115: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	116: oInstruction = { `BLE , `DRW_WEST, `ROWS, `Y_LIMIT};
	117: oInstruction = { `JMP , `EVIL_MOVE, 16'b0 };
	118: oInstruction = { `NOP ,	24'd4000	};
	119: oInstruction = { `BLE , `DELAY, `POSITIONY, `LED_DATA};
	120: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	121: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	122: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	123: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	124: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	125: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	126: oInstruction = { `VGA , `BLUE,5'b0 , `COLS, `ROWS  };
	127: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	128: oInstruction = { `BLE , `DEL_NORTH, `COLS, `X_LIMIT};
	129: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	130: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	131: oInstruction = { `BLE , `DEL_NORTH, `ROWS, `Y_LIMIT};
	132: oInstruction = { `SUB , `POSITIONY, `POSITIONY, `SIZE};
	133: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	134: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	135: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	136: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	137: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	138: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	139: oInstruction = { `VGA , `GREEN,5'b0 , `COLS, `ROWS  };
	140: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	141: oInstruction = { `BLE , `DRW_NORTH, `COLS, `X_LIMIT};
	142: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	143: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	144: oInstruction = { `BLE , `DRW_NORTH, `ROWS, `Y_LIMIT};
	145: oInstruction = { `JMP , `EVIL_MOVE, 16'b0 };
	146: oInstruction = { `NOP ,	24'd4000	};
	147: oInstruction = { `BLE , `DELAY, `X_MAX, `POSITIONY};
	148: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	149: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	150: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	151: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	152: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	153: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	154: oInstruction = { `VGA , `BLUE,5'b0 , `COLS, `ROWS  };
	155: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	156: oInstruction = { `BLE , `DEL_SOUTH, `COLS, `X_LIMIT};
	157: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	158: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	159: oInstruction = { `BLE , `DEL_SOUTH, `ROWS, `Y_LIMIT};
	160: oInstruction = { `ADD , `POSITIONY, `POSITIONY, `SIZE};
	161: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	162: oInstruction = { `CPY , `ROWS, `POSITIONY, `POSITIONY };
	163: oInstruction = { `CPY , `X_LIMIT, `POSITIONX, `POSITIONX };
	164: oInstruction = { `CPY , `Y_LIMIT, `POSITIONY, `POSITIONY };
	165: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	166: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	167: oInstruction = { `VGA , `GREEN,5'b0 , `COLS, `ROWS  };
	168: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	169: oInstruction = { `BLE , `DRW_SOUTH, `COLS, `X_LIMIT};
	170: oInstruction = { `CPY , `COLS, `POSITIONX, `POSITIONX };
	171: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	172: oInstruction = { `BLE , `DRW_SOUTH, `ROWS, `Y_LIMIT};
	173: oInstruction = { `JMP , `EVIL_MOVE, 16'b0 };
	174: oInstruction = { `NOP ,	24'd4000	};
	175: oInstruction = { `CPY , `COLS, `EVIL_X, `EVIL_X };
	176: oInstruction = { `CPY , `ROWS, `EVIL_Y, `EVIL_Y };
	177: oInstruction = { `CPY , `X_LIMIT, `EVIL_X, `EVIL_X };
	178: oInstruction = { `CPY , `Y_LIMIT, `EVIL_Y, `EVIL_Y };
	179: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	180: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	181: oInstruction = { `VGA , `BLUE,5'b0 , `COLS, `ROWS  };
	182: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	183: oInstruction = { `BLE , `DEL_EVIL, `COLS, `X_LIMIT};
	184: oInstruction = { `CPY , `COLS, `EVIL_X, `EVIL_X };
	185: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	186: oInstruction = { `BLE , `DEL_EVIL, `ROWS, `Y_LIMIT};
	187: oInstruction = { `BLE , `EVL_RIGHT, `EVIL_X, `POSITIONX};
	188: oInstruction = { `SUB , `EVIL_X, `EVIL_X, `SIZE}; //  Me muevo a la izquierda 
	189: oInstruction = { `JMP , `DECIDE_Y, 16'b0 };
	190: oInstruction = { `ADD , `EVIL_X, `EVIL_X, `SIZE}; //  Me muevo a la derecha 
	191: oInstruction = { `BLE , `EVL_DOWN, `EVIL_Y, `POSITIONY};
	192: oInstruction = { `SUB , `EVIL_Y, `EVIL_Y, `SIZE}; //  Me muevo a la arriba 
	193: oInstruction = { `JMP , `PAINT_EVIL, 16'b0 };
	194: oInstruction = { `ADD , `EVIL_Y, `EVIL_Y, `SIZE}; //  Me muevo a la abajo 
	195: oInstruction = { `CPY , `COLS, `EVIL_X, `EVIL_X };
	196: oInstruction = { `CPY , `ROWS, `EVIL_Y, `EVIL_Y };
	197: oInstruction = { `CPY , `X_LIMIT, `EVIL_X, `EVIL_X };
	198: oInstruction = { `CPY , `Y_LIMIT, `EVIL_Y, `EVIL_Y };
	199: oInstruction = { `ADD , `X_LIMIT, `SIZE, `X_LIMIT};
	200: oInstruction = { `ADD , `Y_LIMIT, `SIZE, `Y_LIMIT};
	201: oInstruction = { `VGA , `RED,5'b0 , `COLS, `ROWS  };
	202: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	203: oInstruction = { `BLE , `DRW_EVIL, `COLS, `X_LIMIT};
	204: oInstruction = { `CPY , `COLS, `EVIL_X, `EVIL_X };
	205: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	206: oInstruction = { `BLE , `DRW_EVIL, `ROWS, `Y_LIMIT};
	207: oInstruction = { `JMP , `DELAY, 16'b0 };
	208: oInstruction = { `STO , `COLS, 16'b0};
	209: oInstruction = { `STO , `ROWS, 16'b0};
	210: oInstruction = { `NOP ,	24'd4000	};
	211: oInstruction = { `VGA , `WHITE,5'b0 , `COLS, `ROWS  };
	212: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	213: oInstruction = { `BLE , `END_LOOP, `COLS, `COLS_SIZE};
	214: oInstruction = { `STO , `COLS, 16'b0};
	215: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	216: oInstruction = { `BLE , `END_LOOP, `ROWS, `ROWS_SIZE};
	217: oInstruction = { `NOP ,	24'd4000	};
	218: oInstruction = { `JMP , `END, 16'b0 };


	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
