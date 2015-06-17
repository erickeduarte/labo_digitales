define COLS		8'b0
define ROWS 	8'b1
define ONE 		8'd2
define COLS_SIZE 	8'd3
define ROWS_SIZE	8'd4
define STRIPE_SIZE  8'd5

NOP
STO 	`COLS 16'b0
STO 	`ROWS 16'b0
STO 	`ONE  16'b1
STO		`COLS_SIZE 		16'd99
STO 	`ROWS_SIZE 		16'd24
STO		`STRIPE_SIZE 	16'd25

/////////////////////////
define GREENLOOP 8'd7 
/////////////////////////
NOP
VGA 	`COLOR_GREEN `COLS `ROWS
ADD 	`COLS `COLS `ONE
BLE 	`GREENLOOP `COLS `COLS_SIZE
STO 	`COLS 16'b0
/////////////////////////
ADD 	`ROWS `ROWS `ONE
BLE 	`GREENLOOP `ROWS `ROWS_SIZE

ADD `ROWS_SIZE `ROWS_SIZE `STRIPE_SIZE

/////////////////////////
define REDLOOP 8'd14
/////////////////////////

NOP
VGA 	`COLOR_RED `COLS `ROWS
ADD 	`COLS `COLS `ONE
BLE 	`REDLOOP `COLS `COLS_SIZE
STO 	`COLS 16'b0
/////////////////////////
ADD 	`ROWS `ROWS `ONE
BLE 	`REDLOOP `ROWS `ROWS_SIZE

ADD `ROWS_SIZE `ROWS_SIZE `STRIPE_SIZE
//-----------------------
define WHITELOOP 8'd21 
/////////////////////////
NOP
VGA 	`COLOR_RED `COLS `ROWS
ADD 	`COLS `COLS `ONE
BLE 	`WHITELOOP `COLS `COLS_SIZE
STO 	`COLS 16'b0
/////////////////////////
ADD 	`ROWS `ROWS `ONE
BLE 	`WHITELOOP `ROWS `ROWS_SIZE

ADD `ROWS_SIZE `ROWS_SIZE `STRIPE_SIZE
//-----------------------
define BLUELOOP 8'd28 
/////////////////////////
NOP
VGA 	`COLOR_RED `COLS `ROWS
ADD 	`COLS `COLS `ONE
BLE 	`BLUELOOP `COLS `COLS_SIZE
STO 	`COLS 16'b0
/////////////////////////
ADD 	`ROWS `ROWS `ONE
BLE 	`BLUELOOP `ROWS `ROWS_SIZE


/////////////////////////
NOP
JMP 8'd38
///
