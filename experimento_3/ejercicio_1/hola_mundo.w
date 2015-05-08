STO		8'b1	16'hffff
NOP			
LED		8'b1		
NOP
BNLCD	8'd4  			// 	Loop untill LCD display is ready
LCD		8'b01001000		//	H is 01001000 -- Write to LCD
NOP
BNLCD	8'd6			//	Loop untill LCD display is ready
LCD		8'b01001111		//	O is 01001111-- Write to LCD
NOP
BNLCD	8'd9			//	Loop untill LCD display is ready
LCD		8'b01001100		//	L is 01001110 -- Write to LCD
NOP
BNLCD	8'd12			//	Loop untill LCD display is ready
LCD		8'b01000001		//	A is 01000001 -- Write to LCD
NOP
BNLCD	8'd15 			// 	Loop untill LCD display is ready
LCD		8'b00100000		//	SPACE is 00100000 -- Write to LCD
NOP
BNLCD	8'd18  			// 	Loop untill LCD display is ready
LCD		8'b01001101		//	M is 01001101 -- Write to LCD
NOP
BNLCD	8'd21  			// 	Loop untill LCD display is ready
LCD		8'b01010101		//	U is 01010101 -- Write to LCD
NOP	
BNLCD	8'd24  			// 	Loop untill LCD display is ready
LCD		8'b01001110		//	N is 01001110 -- Write to LCD
NOP
BNLCD	8'd27  			// 	Loop untill LCD display is ready
LCD		8'b01000100		//	D is 01000100 -- Write to LCD
NOP
BNLCD	8'd30 			// 	Loop untill LCD display is ready
LCD		8'b01001111		//	O is 01001111 -- Write to LCD
NOP
BNLCD	8'd33  			// 	Loop untill LCD display is ready
LCD		8'b00100001		//	! is 00100001 -- Write to LCD
NOP
JMP    8'd36
