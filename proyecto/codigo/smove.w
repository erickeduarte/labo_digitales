define COLS			8'b0
define ROWS 		8'b1
define ONE 			8'd2
define COLS_SIZE 	8'd3
define ROWS_SIZE	8'd4
define POSITIONX  	8'd5
define POSITIONY  	8'd6
define EVIL_X		8'd7 
define EVIL_Y		8'd8
define COUNT    	8'd9
define MAX_COUNT	8'd10
define X_LIMIT		8'd11
define Y_LIMIT		8'd12
define SIZE			8'd13
define LED_DATA		8'd14
define X_MAX		8'd15
define Y_MAX		8'd16
define COUNT2		8'd11
//
// Initialize values
// 

NOP
STO 	`COLS 16'b0
STO 	`ROWS 16'b0
STO 	`ONE  16'b1
STO		`COLS_SIZE 		16'd99
STO 	`ROWS_SIZE 		16'd99
STO		`MAX_COUNT		16'd2000
STO		`SIZE			16'd4
STO		`LED_DATA		16'b1111111111111111
STO		`X_MAX			16'd94
STO		`Y_MAX			16'd94
NOP


//
// Fill screen with solid color
// 

define GREENLOOP 	NEXTLINE

NOP
VGA 	`BLUE 			`COLS `ROWS
ADD 	`COLS 	`COLS 	`ONE
BLE 	`GREENLOOP 		`COLS `COLS_SIZE
STO 	`COLS 			16'b0

ADD 	`ROWS 			`ROWS `ONE
BLE 	`GREENLOOP 		`ROWS `ROWS_SIZE


//
// FIELD INITIALIZED
//

//GREEN SQUARE

STO		`POSITIONX		16'd50	// Initial position 
STO		`POSITIONY		16'd50	// Initial position
CPY		`POSITIONX		`COLS	
CPY		`POSITIONY		`ROWS
CPY		`POSITIONX		`X_LIMIT
CPY		`POSITIONY		`Y_LIMIT
ADD		`X_LIMIT		`SIZE		`X_LIMIT
ADD		`Y_LIMIT		`SIZE		`Y_LIMIT
// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE
define 	LOOP2		NEXTLINE
VGA		`GREEN		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`LOOP2 		`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`LOOP2 		`ROWS 		`Y_LIMIT
JMP 	`DECIDE
//
// Player initialized
//

//
// Delay Loop
//

define 	DELAY		NEXTLINE
STO		`COUNT		16'b0
LED 	`LED_DATA
define 	DELAY1 	NEXTLINE
STO		`COUNT2		16'b0
define 	DELAY2	NEXTLINE
ADD		`COUNT2		`ONE		`COUNT2
BLE		`DELAY2 	`COUNT2		`MAX_COUNT
ADD		`COUNT		`ONE		`COUNT
BLE		`DELAY1		`COUNT		`MAX_COUNT	

////////////////////////////////////////////////////////////////////////
//	READ PLAYER ACTION
////////////////////////////////////////////////////////////////////////

define	DECIDE		NEXTLINE
BEAST	`MOVE_EAST
BSOUTH	`MOVE_SOUTH
BNORTH	`MOVE_NORTH
BWEST	`MOVE_WEST	
JMP 	`DECIDE

////////////////////////////////////////////////////////////////////////
// ---------------------------
//	MOVE EAST
// ---------------------------

// Initialize values

define 	MOVE_EAST	NEXTLINE
NOP

// Check that we can move

BLE		`DELAY		`X_MAX   	`POSITIONX

ADD 	`POSITIONX   `POSITIONX		`SIZE

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	LOOP2		NEXTLINE
VGA		`GREEN		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`LOOP2 		`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`LOOP2 		`ROWS 		`Y_LIMIT

JMP		`DELAY
/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
define 	MOVE_WEST	NEXTLINE
// ---------------------------
//	MOVE WEST
// ---------------------------
NOP

// Check that we can move

BLE		`DELAY		 `POSITIONX		`ONE

SUB 	`POSITIONX   `POSITIONX		`SIZE

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	LOOP3		NEXTLINE
VGA		`GREEN		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`LOOP3 		`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`LOOP3 		`ROWS 		`Y_LIMIT

JMP		`DELAY

/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
define 	MOVE_NORTH	NEXTLINE
// ---------------------------
//	MOVE NORTH
// ---------------------------
NOP

// Check that we can move

BLE		`DELAY			`POSITIONY 		`ONE

SUB 	`POSITIONY  	`POSITIONY		`SIZE

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	LOOP4		NEXTLINE
VGA		`GREEN		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`LOOP4 		`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`LOOP4 		`ROWS 		`Y_LIMIT

JMP		`DELAY

/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
define 	MOVE_SOUTH	NEXTLINE
// ---------------------------
//	MOVE SOUTH
// ---------------------------
NOP

// Check that we can move

BLE		`DELAY		`X_MAX   	`POSITIONY

ADD 	`POSITIONY   `POSITIONY		`SIZE

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	LOOP2		NEXTLINE
VGA		`GREEN		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`LOOP2 		`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`LOOP2 		`ROWS 		`Y_LIMIT

JMP		`DELAY

/////////////////////////////////////////////////////////////////////////

//
// END
//

define		END			NEXTLINE
NOP
JMP			`END
