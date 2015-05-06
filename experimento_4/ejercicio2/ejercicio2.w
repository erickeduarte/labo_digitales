define COLS 8'b0
define ROWS 8'b1
define ONE 8'd2
NOP
STO 	`COLS 16'b0
STO 	`ROWS 16'b0
STO 	`ONE  16'b1
/////////////////////////
define GREENLOOP 8'd4 
/////////////////////////
NOP
VGA 	`COLOR_GREEN `COLS `ROWS
ADD 	`COLS `COLS `ONE
BLE 	`GREENLOOP `COLS 8'd255
/////////////////////////
ADD 	`ROWS `ROWS `ONE
BLE 	`GREENLOOP `ROWS 8'd63

//-----------------------
define REDLOOP 8'd10
/////////////////////////
NOP
VGA 	`COLOR_RED `COLS `ROWS
ADD 	`COLS `COLS `ONE
BLE 	`REDLOOP `COLS 8'd255
/////////////////////////
ADD 	`ROWS `ROWS `ONE
BLE 	`REDLOOP `ROWS 8'd127

//-----------------------
define WHITELOOP 8'd16 
/////////////////////////
NOP
VGA 	`COLOR_RED `COLS `ROWS
ADD 	`COLS `COLS `ONE
BLE 	`WHITELOOP `COLS 8'd255
/////////////////////////
ADD 	`ROWS `ROWS `ONE
BLE 	`WHITELOOP `ROWS 8'd191

//-----------------------
define BLUELOOP 8'd22 
/////////////////////////
NOP
VGA 	`COLOR_RED `COLS `ROWS
ADD 	`COLS `COLS `ONE
BLE 	`BLUELOOP `COLS 8'd255
/////////////////////////
ADD 	`ROWS `ROWS `ONE
BLE 	`BLUELOOP `ROWS 8'd255

/////////////////////////
NOP
JMP 8'd28
///
