NOP
BNLCD	8'b0  			// 	Loop untill LCD display is ready
LCD		8'b01001000		//	H is 01001000 -- Write to LCD
NOP
BNLCD	8'd3			//	Loop untill LCD display is ready
LCD		8'b01001111		//	O is 01001111-- Write to LCD
NOP
BNLCD	8'd3			//	Loop untill LCD display is ready
LCD		8'b01001100		//	L is 01001110 -- Write to LCD
NOP
BNLCD	8'd3			//	Loop untill LCD display is ready
LCD		8'b01000001		//	A is 01000001 -- Write to LCD
NOP
