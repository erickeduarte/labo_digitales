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
STO		`LED_DATA		16'b0101
STO		`X_MAX			16'd94
STO		`Y_MAX			16'd94
NOP

//
// Fill screen with solid color
// 

define INIT_LOOP 	NEXTLINE

NOP
VGA 	`BLUE 			`COLS 	`ROWS
ADD 	`COLS 			`COLS 	`ONE
BLE 	`INIT_LOOP 		`COLS 	`COLS_SIZE
STO 	`COLS 			16'b0

ADD 	`ROWS 			`ROWS `ONE
BLE 	`INIT_LOOP 		`ROWS `ROWS_SIZE


//
// FIELD INITIALIZED
//

// RED SQUARE

STO		`EVIL_X		16'd02	// Initial position EVILX
STO		`EVIL_Y		16'd02	// Initial position	EVILY
CPY		`EVIL_X		`COLS	
CPY		`EVIL_Y		`ROWS
CPY		`EVIL_X		`X_LIMIT
CPY		`EVIL_Y		`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE
define 	INIT_EVIL	NEXTLINE
VGA		`RED		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`INIT_EVIL 	`COLS 		`X_LIMIT
CPY 	`EVIL_X 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`INIT_EVIL 	`ROWS 		`Y_LIMIT

//
// Evil initialized
//

STO		`POSITIONX		16'd50	// Initial position 
STO		`POSITIONY		16'd50	// Initial position
CPY		`POSITIONX		`COLS	
CPY		`POSITIONY		`ROWS
CPY		`POSITIONX		`X_LIMIT
CPY		`POSITIONY		`Y_LIMIT
ADD		`X_LIMIT		`SIZE		`X_LIMIT
ADD		`Y_LIMIT		`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE
define 	PLYR_INIT		NEXTLINE
VGA		`GREEN		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`PLYR_INIT 	`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`PLYR_INIT 	`ROWS 		`Y_LIMIT

//
// PLAYER INITIALIZED
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

BEAST	`MOVE_EAST
BSOUTH	`MOVE_SOUTH
BNORTH	`MOVE_NORTH
BWEST	`MOVE_WEST	
BCLOSE	`CLOSE_X	`POSITIONX	`EVIL_X
JMP 	`DELAY

define 	CLOSE_X		NEXTLINE
BCLOSE 	`GAME_OVER	`POSITIONY	`EVIL_Y
JMP		`DELAY 	
////////////////////////////////////////////////////////////////////////
// ---------------------------
//	MOVE EAST
// ---------------------------

// Initialize values

define 	MOVE_EAST	NEXTLINE
NOP

// Check that we can move

BLE		`DELAY		`X_MAX   	`POSITIONX

// Delete current position

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	DEL_EAST	NEXTLINE
VGA		`BLUE		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`DEL_EAST 	`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`DEL_EAST 	`ROWS 		`Y_LIMIT

// Draw square in new position 

ADD 	`POSITIONX   `POSITIONX		`SIZE

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	DRW_EAST	NEXTLINE
VGA		`GREEN		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`DRW_EAST 		`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`DRW_EAST 		`ROWS 		`Y_LIMIT

JMP		`EVIL_MOVE
/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
define 	MOVE_WEST	NEXTLINE
// ---------------------------
//	MOVE WEST
// ---------------------------
NOP

// Check that we can move

BLE		`DELAY		 `POSITIONX		`LED_DATA

// Delete current position

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	DEL_WEST	NEXTLINE
VGA		`BLUE		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`DEL_WEST 	`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`DEL_WEST 	`ROWS 		`Y_LIMIT

// Draw new position

SUB 	`POSITIONX   `POSITIONX		`SIZE

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	DRW_WEST		NEXTLINE
VGA		`GREEN		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`DRW_WEST 	`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`DRW_WEST 	`ROWS 		`Y_LIMIT

JMP		`EVIL_MOVE

/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
define 	MOVE_NORTH	NEXTLINE
// ---------------------------
//	MOVE NORTH
// ---------------------------
NOP

// Check that we can move

BLE		`DELAY			`POSITIONY 		`LED_DATA

// Delete old position

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	DEL_NORTH	NEXTLINE
VGA		`BLUE		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`DEL_NORTH 	`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`DEL_NORTH 	`ROWS 		`Y_LIMIT


// Draw new position
 
SUB 	`POSITIONY  	`POSITIONY		`SIZE

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	DRW_NORTH		NEXTLINE
VGA		`GREEN		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`DRW_NORTH 		`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`DRW_NORTH 		`ROWS 		`Y_LIMIT

JMP		`EVIL_MOVE

/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
define 	MOVE_SOUTH	NEXTLINE
// ---------------------------
//	MOVE SOUTH
// ---------------------------
NOP

// Check that we can move

BLE		`DELAY		`X_MAX   	`POSITIONY

// Delete old position

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	DEL_SOUTH	NEXTLINE
VGA		`BLUE		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`DEL_SOUTH 	`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`DEL_SOUTH 	`ROWS 		`Y_LIMIT

// Draw new position

ADD 	`POSITIONY   `POSITIONY		`SIZE

CPY		`POSITIONX	`COLS	
CPY		`POSITIONY	`ROWS
CPY		`POSITIONX	`X_LIMIT
CPY		`POSITIONY	`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	DRW_SOUTH		NEXTLINE
VGA		`GREEN		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`DRW_SOUTH 		`COLS 		`X_LIMIT
CPY 	`POSITIONX 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`DRW_SOUTH 		`ROWS 		`Y_LIMIT

JMP		`EVIL_MOVE

/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
//
//	EVIL CODE
//
define EVIL_MOVE NEXTLINE
NOP

// Check that we can move


// Delete old position

CPY		`EVIL_X		`COLS	
CPY		`EVIL_Y		`ROWS
CPY		`EVIL_X		`X_LIMIT
CPY		`EVIL_Y		`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	DEL_EVIL	NEXTLINE
VGA		`BLUE		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`DEL_EVIL 	`COLS 		`X_LIMIT
CPY 	`EVIL_X 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`DEL_EVIL 	`ROWS 		`Y_LIMIT

//
// Calculate new position
//

BLE 	`EVL_RIGHT 	`EVIL_X 	`POSITIONX
SUB 	`EVIL_X  	`EVIL_X		`SIZE		// Me muevo a la izquierda
JMP		`DECIDE_Y
define	EVL_RIGHT	NEXTLINE
ADD 	`EVIL_X   	`EVIL_X		`SIZE		// Me muevo a la derecha

define 	DECIDE_Y	NEXTLINE
BLE 	`EVL_DOWN 	`EVIL_Y 	`POSITIONY
SUB 	`EVIL_Y  	`EVIL_Y		`SIZE		// Me muevo a la arriba
JMP		`PAINT_EVIL
define	EVL_DOWN	NEXTLINE
ADD 	`EVIL_Y   	`EVIL_Y		`SIZE		// Me muevo a la abajo

//
//	New position calculated
//
define 	PAINT_EVIL	NEXTLINE

CPY		`EVIL_X		`COLS	
CPY		`EVIL_Y		`ROWS
CPY		`EVIL_X		`X_LIMIT
CPY		`EVIL_Y		`Y_LIMIT
ADD		`X_LIMIT	`SIZE		`X_LIMIT
ADD		`Y_LIMIT	`SIZE		`Y_LIMIT

// Paint from POS X and POS Y, to POS X + SIZE to POS y + SIZE

define 	DRW_EVIL		NEXTLINE
VGA		`RED		`COLS		`ROWS
ADD 	`COLS 		`COLS 		`ONE
BLE 	`DRW_EVIL	`COLS 		`X_LIMIT
CPY 	`EVIL_X 	`COLS
ADD 	`ROWS 		`ROWS 		`ONE
BLE 	`DRW_EVIL 	`ROWS 		`Y_LIMIT

JMP		`DELAY
/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
// GAME OVER
/////////////////////////////////////////////////////////////////////////
define GAME_OVER	NEXTLINE

//
// Fill screen with solid color
// 
STO 	`COLS 16'b0
STO 	`ROWS 16'b0

define END_LOOP 	NEXTLINE

NOP
VGA 	`WHITE 			`COLS 	`ROWS
ADD 	`COLS 			`COLS 	`ONE
BLE 	`END_LOOP 		`COLS 	`COLS_SIZE
STO 	`COLS 			16'b0

ADD 	`ROWS 			`ROWS `ONE
BLE 	`END_LOOP 		`ROWS `ROWS_SIZE


/////////////////////////////////////////////////////////////////////////
//
// END
//

define		END			NEXTLINE
NOP
JMP			`END
