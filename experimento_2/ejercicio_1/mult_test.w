NOP
STO 	`R2		16'd65000
STO		`R1		16'd1 
STO		`R7		16d5 
STO		`R6		16'd4  
MUL		`R5		`R6		`R7
LED		8'b0	`R5		8'b0
ADD		`R3		`R1		`R3  
BLE		`SIGUE1	`R1		`R2
STO		`R7		16'd5
STO		`R6		16'd4
MUL		`R5		`R		`R7
LED		8'b0	`R5		8'b0
ADD		`R3		`R1		`R3  
BLE		`SIGUE	`R1		`R2
SMUL	`R5		`R6		`R7
