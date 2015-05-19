define COLS 8'b0
define ROWS 8'b1
define ONE 8'd2
define SQUARE 8'd3
define NEWROW 8'd4
define INITIALCOLOR 8'd5

/////////////////////////
NOP
STO 	`COLS      16'b0
STO 	`ROWS      16'b0
STO 	`ONE       16'b1
STO 	`SQUARE    16'd31
STO		`NEWROW    16'd31
/////////////////////////
define WHITELOOP 8'd6 
/////////////////////////
NOP
STO		`INITIALCOLOR 16'd1
VGA 	`COLOR_WHITE `COLS `ROWS
ADD 	`COLS `COLS `ONE
BLE 	`WHITELOOP `COLS `SQUARE
/////////////////////////
ADD 	`ROWS `ROWS `ONE
BLE 	`WHITELOOP `ROWS `NEWROW

//-----------------------

NOP
SUB		`ROWS `ROWS 8'd32
ADD     `SQUARE `SQUARE 8'd32
//-----------------------
define BLACKLOOP 8'd16
/////////////////////////
NOP
STO 	`INITIALCOLOR 16'd0
VGA 	`COLOR_BLACK `COLS `ROWS
ADD 	`COLS `COLS `ONE
BLE 	`BLACKLOOP `COLS `SQUARE 
/////////////////////////
ADD 	`ROWS `ROWS `ONE
BLE 	`BLACKLOOP `ROWS `NEWROW


//------------------------
//////NEW PAIR OF SQUARES///////
SUB		`ROWS `ROWS 8'd32
BLE 	`WHITELOOP `COLS `8'd255

//-----------------------
///////NEW ROW//////////////
NOP
STO 	`COLS 16'b0
ADD 	`NEWROW `NEWROW 8'd32
BLE 	`WHITELOOP `INITIALCOLOR 8'd0
BLE 	`BLACKLOOP `ROWS 8'd255

/////////////////////////
NOP
JMP 	8'd30
///
